#!/bin/bash

usrchooseinit=""
likernel=""

#read -p "choose you init after install " usrchooseinit
basestrap /mnt base base-devel $usrchooseinit elogind-$usrchooseinit

#read -p "Choose kernel " likernel
if [[ "$likernel" != "default" ]]; then
. basestrap /mnt linux-$likernel linux-firmware
else
  basestrap /mnt linux linux-firmware
fi

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
