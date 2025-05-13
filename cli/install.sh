#!/bin/sh
cargo build -r || exit;
echo "Copying release to /usr/bin"
sudo cp target/release/asus /usr/bin/asus
echo "Finished installing"
