pushd yamlrs
cargo build
export LD_LIBRARY_PATH=$PWD/target/debug
popd

pushd ../yoml
pds
make
popd

./build/release/yoml/yoml.native
