(*
pushd ../yamlrs && cargo build && popd
export LD_LIBRARY_PATH=../yamlrs/target/debug

ocamlfind ocamlopt \
   -ccopt -L../yamlrs/target/debug \
   -ccopt -lyamlrs \
   -linkpkg -package ctypes.foreign \
   -o yoooml \
   ./main.ml

./yoooml
*)

open Ctypes
open Foreign

let lib = Dl.dlopen ~filename:"libyamlrs.so" ~flags:[ Dl.RTLD_NOW ]

(* matches rust struct *)
type key_value

let key_value : key_value structure typ = structure "KeyValue"
let key = field key_value "key" (ptr char)
let value = field key_value "value" (ptr char)
let () = seal key_value

(* bindings for yamlrs.parse_yaml *)
let parse_yaml =
  foreign ~from:lib "parse_yaml"
    (ptr uint8_t @-> size_t @-> returning (ptr_opt key_value))

(* bindings for yamlrs.free_key_value *)
let free_key_value =
  foreign ~from:lib "free_key_value" (ptr key_value @-> returning void)

(* converts c-string to ocaml string *)
let string_from_c_ptr (p : char ptr) : string =
  if p = from_voidp char null then "" else coerce (ptr char) string p

(* the parse function *)
let parse str =
  let len = String.length str in
  let buf = CArray.of_string str in
  let input_ptr = coerce (ptr char) (ptr uint8_t) (CArray.start buf) in
  match parse_yaml input_ptr (Unsigned.Size_t.of_int len) with
  | None -> None
  | Some kv_ptr ->
      let kv = !@kv_ptr in
      let k = string_from_c_ptr (getf kv key) in
      let v = string_from_c_ptr (getf kv value) in
      free_key_value kv_ptr;
      Some (k, v)

let () =
  let yaml = "name: ocaml" in
  match parse yaml with
  | Some (k, v) -> Printf.printf "Parsed: %s => %s\n" k v
  | None -> Printf.printf "Failed to parse YAML\n"
