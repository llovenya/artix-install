#!/bin/bash
initsystem="$(ps -p 1 -o comm=)"

while ! ping -c2 artixlinux.org  ; do
  clear
  connmanctl agent on
  connmanctl enable wifi
  connmanctl services
  read -p "Wireless SSID " SSID
  SERVICE_ID=$(connmanctl services | grep "$SSID" | awk '{print $3}')
  connmanctl connect "$SERVICE_ID"
done

echo $initsystem

case initsystem in
  dinit)
     dinitctl start ntpd
    ;;
  s6)
     s6-rc -u change ntpd
    ;;
  runit)
     sv up ntpd
    ;;
  openrc)
     rc-service ntpd start
    ;;
esac

pacman-key --init
pacman-key --populate artix
pacman -Syu
echo Ok

