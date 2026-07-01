#!/usr/bin/bash

echo "Clear existing plasmoid folder"
rm -fr ~/.local/share/plasma/plasmoids/kasus.widget/* || exit;

echo "Copy plasmoid files"
cp -r contents ~/.local/share/plasma/plasmoids/kasus.widget/  || exit;
cp metadata.json ~/.local/share/plasma/plasmoids/kasus.widget/  || exit;

echo "Restarting the shell"
systemctl restart --user plasma-plasmashell
echo "Finished installing asus qt widget"
