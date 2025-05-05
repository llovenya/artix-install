eval "$(grep '^boot=' vars.sh)"  
disk=""
bootdisk=""
rootdisk=""
swapdisk=""
homedisk=""
filesystem=""
HOMEIS=""
SWAP=""

#lsblk
#read -p "/dev/" disk
cfdisk "/dev/$disk" 
#clear

if [[ "$boot" == "UEFI" ]]; then
#  lsblk
#  read -p "Choose boot disk /dev/" bootdisk
  mkfs.fat -F 32 "/dev/$bootdisk"
  fatlabel "/dev/$bootdisk" ESP
fi

#read -p "Swap? yes/no " SWAP

if [[ "$SWAP" == "yes" ]]; then
#  lsblk
#  read -p "Choose swap disk /dev/" swapdisk
  mkswap -L SWAP "/dev/$swapdisk"
fi

#  read -p "Choose filesystem for root/user/boot(If not UEFI) (btrfs, ext4) " filesystem

#$read -p "Choose root disk /dev/" rootdisk
#  read -p "You need home directory? yes/no " HOMEIS
  #if [[ "$HOMEIS" == "yes" ]]; then
  #read -p "Choose home disk /dev/" homedisk
  #fi
#if [[ "$boot" != "BIOS" ]]; then
#  read -p "Choose boot disk /dev" bootdisk
#fi

if [[ "$filesystem" == "ext4" ]]; then
  mkfs.ext4 -L ROOT /dev/$rootdisk
  if [[ "$HOMEIS" == "yes" ]]; then
  mkfs.ext4 -L HOME /dev/$homedisk
  fi
  if [[ "$boot" != "BIOS" ]]; then
  mkfs.ext4 -L BOOT /dev/$bootdisk
  fi
fi

if [[ "$filesystem" == "btrfs" ]]; then
  mkfs.btrfs -L ROOT /dev/$rootdisk
  if [[ "$HOMEIS" == "yes" ]]; then
  mkfs.btrfs -L HOME /dev/$homedisk
  fi
  if [[ "$boot" != "UEFI" ]]; then
    mkfs.btrfs -L BOOT /dev/$bootdisk
  fi
fi

#clear
mount /dev/disk/by-label/ROOT /mnt
mkdir /mnt/boot
if [[ "$HOMEIS" == "yes" ]]; then
  mkdir /mnt/home
  mount /dev/disk/by-label/HOME /mnt/home
fi
if [[ "$boot" == "UEFI" ]]; then
  mkdir /mnt/boot/efi
  mount /dev/disk/by-label/ESP /mnt/boot/efi
fi
if [[ "$boot" == "BIOS" ]]; then
 mount /dev/disk/by-label/BOOT /mnt/boot
fi
#clear

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
update_var rootdisk "$rootdisk"
update_var swapdisk "$swapdisk"
update_var homedisk "$homedisk"
update_var filesystem "$filesystem"
update_var HOMEIS "$HOMEIS"
update_var SWAP "$SWAP"

artix-chroot /mnt
