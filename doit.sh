printf "\nBUILDING RUST\n"
pushd rust
cargo build
export LD_LIBRARY_PATH=$PWD/target/debug
popd

printf "\nBUILDING OCAML\n"
pushd ocaml
pds
make
popd

printf "\nRUNNING YOML\n"
./ocaml/build/release/yoml/yoml.native
