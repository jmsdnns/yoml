# Yoml

![lol](fun_yoml.png)

A proof-of-concept demonstrating how to build a yaml parsing library in Rust that gets used via FFI in Ocaml.
🐫 🦀

Who knows, maybe it'll be a thing one day.

## Overview

Clone this repo, build the yamlrs, then build yoml.

```shell
git clone https://github.com/jmsdnns/yoml && cd yoml

cd yamlrs
cargo build 
export LD_LIBRARY_PATH=$PWD/target/debug

cd ../yoml
ocamlfind ocamlopt \
   -ccopt -L../yamlrs/target/debug \
   -ccopt -lyamlrs \
   -linkpkg -package ctypes.foreign \
   -o yoooml \
   ./main.ml

