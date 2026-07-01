#!/usr/bin/bash

cargo build -r || exit;
echo "Copying release to /usr/bin"
sudo cp target/release/asus /usr/bin/asus || exit;
echo "Finished installing asus cli"
