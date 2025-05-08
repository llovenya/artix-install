#!/usr/bin/bash

chmod +x read.sh
chmod +x network.sh
chmod +x autoinstall.sh

./network.sh
./read.sh
script -q -c "./autoinstall.sh" logfile.txt
./autoinstall.sh
