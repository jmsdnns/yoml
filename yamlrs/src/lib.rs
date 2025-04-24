use serde_yaml::Value;
use std::ffi::CString;
use std::os::raw::c_char;

#[repr(C)]
pub struct KeyValue {
    pub key: *const c_char,
    pub value: *const c_char,
}

#[allow(clippy::not_unsafe_ptr_arg_deref)]
#[unsafe(no_mangle)]
pub extern "C" fn parse_yaml(input: *const u8, len: usize) -> *mut KeyValue {
    if input.is_null() {
        return std::ptr::null_mut();
    }

    let slice = unsafe { std::slice::from_raw_parts(input, len) };
    let yaml_str = match std::str::from_utf8(slice) {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    let parsed: Result<Value, serde_yaml::Error> = serde_yaml::from_str(yaml_str);

    match parsed {
        Ok(Value::Mapping(mapping)) => {
            if let Some((key, value)) = mapping.into_iter().next() {
                let key_str = match key.as_str() {
                    Some(s) => s,
                    None => return std::ptr::null_mut(),
                };
                let value_str = match value.as_str() {
                    Some(s) => s,
                    None => return std::ptr::null_mut(),
                };

                let key_cstr = CString::new(key_str).unwrap();
                let value_cstr = CString::new(value_str).unwrap();
                let kv = KeyValue {
                    key: key_cstr.into_raw(),
                    value: value_cstr.into_raw(),
                };

                Box::into_raw(Box::new(kv))
            } else {
                std::ptr::null_mut()
            }
        }
        _ => std::ptr::null_mut(),
    }
}

#[allow(clippy::not_unsafe_ptr_arg_deref)]
#[unsafe(no_mangle)]
pub extern "C" fn free_key_value(kv: *mut KeyValue) {
    if kv.is_null() {
        return;
    }

    unsafe {
        // frees the pointer
        let kv_box = Box::from_raw(kv);
        if !kv_box.key.is_null() {
            let _ = CString::from_raw(kv_box.key as *mut c_char);
        }
        if !kv_box.value.is_null() {
            let _ = CString::from_raw(kv_box.value as *mut c_char);
        }
    }
}
