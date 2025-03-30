#!/bin/sh
cargo build -r
echo "Copying release to /usr/bin"
sudo cp target/release/asus /usr/bin/asus
echo "Finished installing"
