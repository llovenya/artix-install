#!/usr/bin/bash
exec > >(tee -a logfile.txt) 2>&1

chmod +x read.sh
chmod +x network.sh
chmod +x autoinstall.sh

./network.sh
./read.sh
./autoinstall.sh
