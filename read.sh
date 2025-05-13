#!/usr/bin/bash

#Choose disk
disk=""
while ! [[ -b "/dev/$disk" ]] ; do
  clear
  lsblk
  read -p "Enter disk /dev/" disk
  if ! [[ -b "/dev/$disk" ]]; then
    echo "Disk doesn't exist"
    sleep 2
  fi
done
cfdisk "/dev/$disk" 

#Choose mount 
bootdisk=""
rootdisk=""
swapdisk=""
homedisk=""
filesystem=""
HOMEIS=""
SWAP=""

  while ! [[ -b "/dev/$bootdisk" ]]; do
    clear
    lsblk
    read -p "Choose boot disk /dev/" bootdisk
      if ! [[ -b "/dev/$bootdisk" ]]; then
        echo "Disk doesn't exist"
        sleep 2
      fi
  done

 while ! [[ -b "/dev/$rootdisk" ]]; do
  clear
  lsblk
  read -p "Choose root disk /dev/" rootdisk
    if ! [[ -b "/dev/$rootdisk" ]]; then
      echo "Disk doesn't exist"
      sleep 2
    fi
done

while [[ "$HOMEIS" != "yes" && "$HOMEIS" != "no" ]]; do
  read -p "You need home directory? yes/no " HOMEIS
done
if [[ "$HOMEIS" == "yes" ]]; then
   while ! [[ -b "/dev/$homedisk" ]]; do
    clear
    lsblk
    read -p "Choose home disk /dev/" homedisk
      if ! [[ -b "/dev/$homedisk" ]]; then
        echo "Disk doesn't exist"
        sleep 2
      fi
    done
fi

while [[ "$SWAP" != "yes" && "$SWAP" != "no" ]]; do
read -p "Swap? yes/no " SWAP
done
if [[ "$SWAP" == "yes" ]]; then
   while ! [[ -b "/dev/$swapdisk" ]]; do
    clear
    lsblk
    read -p "Choose swap disk /dev/" swapdisk
      if ! [[ -b "/dev/$swapdisk" ]]; then
        echo "Disk doesn't exist"
        sleep 2
      fi
    done
fi
while [[ "$filesystem" != "ext4" && "$filesystem" != "btrfs" ]]; do
  read -p "Choose filesystem for root/home/boot(If not UEFI) (btrfs, ext4) " filesystem
done
clear

# Init and kernel choose
usrchooseinit=""
likernel=""

while [[ "$usrchooseinit" != "dinit" && "$usrchooseinit" != "openrc" && "$usrchooseinit" != "runit" && "$usrchooseinit" != "s6"   ]]; do
read -p "choose you init after install " usrchooseinit
done
while [[ "$likernel" != "default" && "$likernel" != "zen" && "$likernel" != "lts" && "$likernel" != "rt" && "$likernel" != "rt-lts" && "$likernel" != "ck" ]]; do
  read -p "Choose kernel(default if default) " likernel
done

clear

#System data
rootpass=""
localetime=""
localetimezone=""
localetimedirectory=""
osprober=""
hostname=""
networkin=""
dhcpclient=""
bluetooth=""
locale=""
ntp=""

while [[ -z "$rootpass" || "$rootpass" != "$rootpassrepeat" ]]; do
  clear
  read -sp "Enter new root pass " rootpass
  echo
  read -sp "Repeat your root pass " rootpassrepeat
  if [[ "$rootpass" != "$rootpassrepeat" ]]; then
    echo "Password don't match"
    sleep 2
  elif [[ -z "$rootpass" ]]; then
    echo "Password cannot be empty"
    sleep 2
  fi
done
echo -e "\nPassword set successfully"

while ! [[ -f "/usr/share/zoneinfo/$localetime" ]]; do
  clear
  ls /usr/share/zoneinfo
  read -p "Choose your region " localetime
  if [[ -d "/usr/share/zoneinfo/$localetime" ]]; then
    localetimedirectory="$localetime"
    ls /usr/share/zoneinfo/$localetimedirectory
    read -p "Choose time zone " localetimezone
    localetime="${localetimedirectory}/${localetimezone}"
  fi
  if ! [[ -f "/usr/share/zoneinfo/$localetime" ]]; then
    echo "Incorrect region"
  fi
done

read -p "Choose your text editor: vim, nano, vi ... " texteditor
pacman -S --noconfirm $texteditor
echo "Choose locale, by deleting #"
sleep 2
if ! $texteditor /etc/locale.gen; then
  vi /etc/locale.gen
fi
locale=$(grep -Ev '^\s*(#|$)' /etc/locale.gen | head -n 1 | awk '{print $1}')


while [[ "$osprober" != "yes" && "$osprober" != "no" ]]; do
read -p "dualboot? yes/no " osprober
done

read -p "hostname: " hostname

while [[ "$dhcpclient" != "dhcpcd" && "$dhcpclient" != "dhclient" && "$dhcpclient" != "none" ]]; do
  read -p "dhcpd client: dhcpcd, dhclient, none " dhcpclient
done

while [[ "$networkin" != "connman" && "$networkin" != "networkmanager" && "$networkin" != "none" ]]; do
read -p "connman, networkmanager, none? " networkin
done
echo "After install add to autostart by your init system"

while [[ "$bluetooth" != "yes" && "$bluetooth" != "no" ]]; do
  read -p "Bluetooth yes/no " bluetooth
done

while [[ "$wireless" != "iwd" && "$wireless" != "wpa_supplicant" && "$wireless" != "none" ]]; do
  read -p "Wireless: wpa_supplicant, iwd, none " wireless
done

while [[ "$ntp" != "ntp" && "$ntp" != "openntpd" && "$ntp" != "none" ]]; do
  read -p "ntp, openntpd, none " ntp
done

update_var() {
  local varname=$1
  local varvalue=$2
  local file="vars.sh"

  if grep -q "^export $varname=" "$file" 2>/dev/null; then
    sed -i "s|^export $varname=.*|export $varname=\"$varvalue\"|" "$file"
  else
    echo "export $varname=\"$varvalue\"" >> "$file"
  fi
}

update_var disk "$disk"
update_var bootdisk "$bootdisk"
update_var SWAP "$SWAP"
update_var swapdisk "$swapdisk"
update_var filesystem "$filesystem"
update_var rootdisk "$rootdisk"
update_var homedisk "$homedisk"
update_var HOMEIS "$HOMEIS"
update_var usrchooseinit "$usrchooseinit"
update_var likernel "$likernel"
update_var texteditor "$texteditor"
update_var osprober "$osprober"
update_var rootpass "$rootpass"
update_var dhcpclient "$dhcpclient"
update_var networkin "$networkin"
update_var bluetooth "$bluetooth"
update_var wireless "$wireless"
update_var hostname "$hostname"
update_var locale "$locale"
update_var localetime "$localetime"
update_var ntp "$ntp"

clear

echo "Next, the installation will take place in automatic mode"
sleep 3

