#!/bin/bash

usrchooseinit=""
likernel=""

#read -p "choose you init after install " usrchooseinit

case $usrchooseinit in 
 dinit)
    basestrap /mnt base base-devel dinit elogind-dinit
   ;;
 openrc)
    basestrap /mnt base base-devel openrc elogind-openrc
   ;;
 runit)
     basestrap /mnt base base-devel runit elogind-runit
    ;;
  s6)
     basestrap /mnt base base-devel s6-base elogind-s6
    ;;
esac

#read -p "Choose kernel " likernel

case $likernel in
  default)
    basestrap /mnt linux linux-firmware
    ;;
  zen)
     basestrap /mnt linux-zen linux-firmware
    ;;
  lts)
    basestrap /mnt linux-lts linux-firmware
    ;;
  rt)
     basestrap /mnt linux-rt linux-firmware
    ;;
  rt-lts)
     basestrap /mnt linux-rt-lts linux-firmware
    ;;
  ck)
      basestrap /mnt linux-ck linux-firmware
     ;;
esac

fstabgen -U /mnt >> /mnt/etc/fstab

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

update_var usrchooseinit "$usrchooseinit"
update_var likernel "$likernel"
