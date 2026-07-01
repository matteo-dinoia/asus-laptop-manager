#!/usr/bin/bash

echo -e "\nINSTALLING THE COMMAND LINE INTERFACE..."
cd cli || exit;
./install.sh || exit;
cd .. || exit;

echo -e "\nINSTALLING THE KDE WIDGET..."
cd kasus.widget || exit;
./install.sh || exit;
cd .. || exit;
