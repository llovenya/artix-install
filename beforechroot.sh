#!/bin/bash

partition=""
disk=""
UEFI=""
bootdisk=""
SWAP=""
swapdisk=""
filesystem=""
rootdisk=""
homedisk=""
HOMEIS=""
initsystem=""
likernel=""
texteditor=""
localename=""
osprober=""
userneed=""
username=""
dhcpclient=""
networkin=""
bluetooth=""
wireless=""
echo "Welcome to my Artix install script. Enter to contiune"
read

while [[ "$partition" != "yes" ]]; do
  lsblk
  echo "Choose disk to partition"
  read -p "/dev/" disk
  cfdisk "/dev/$disk" 
  clear
  lsblk
  read -p "Partition is Ok. yes/no? " partition
done
clear

echo "Now formatting partitions"
while [[ "$UEFI" != "yes" && "$UEFI" != "no" ]]; do
  read -p "UEFI? yes/no " UEFI
done
if [[ "$UEFI" == "yes" ]]; then
  lsblk
  read -p "Choose boot disk /dev/" bootdisk
  mkfs.fat -F 32 "/dev/$bootdisk"
  fatlabel "/dev/$bootdisk" ESP
fi

while [[ "$SWAP" != "yes" && "$SWAP" != "no" ]]; do
  read -p "Swap? yes/no " SWAP
done
if [[ "$SWAP" == "yes" ]]; then
  lsblk
  read -p "Choose swap disk /dev/" swapdisk
  mkswap -L SWAP "/dev/$swapdisk"
fi

while [[ "$filesystem" != "btrfs" && "$filesystem" != "ext4" ]]; do
  read -p "Choose filesystem for root/user/boot(If not UEFI) (btrfs, ext4) " filesystem
done

read -p "Choose root disk /dev/" rootdisk
while [[ "$HOMEIS" != "yes" && "$HOMEIS" != "no" ]]; do
  read -p "You need home directory? yes/no " HOMEIS
  if [[ "$HOMEIS" == "yes" ]]; then
  read -p "Choose home disk /dev/" homedisk
  fi
done
if [[ "$UEFI" != "yes" ]]; then
  read -p "Choose boot disk /dev" bootdisk
fi

if [[ "$filesystem" == "ext4" ]]; then
  mkfs.ext4 -L ROOT /dev/$rootdisk
  if [[ "$HOMEIS" == "yes" ]]; then
  mkfs.ext4 -L HOME /dev/$homedisk
  fi
  if [[ "$UEFI" != "yes" ]]; then
  mkfs.ext4 -L BOOT /dev/$bootdisk
  fi
fi

if [[ "$filesystem" == "btrfs" ]]; then
  mkfs.btrfs -L ROOT /dev/$rootdisk
  if [[ "$HOMEIS" == "yes" ]]; then
  mkfs.btrfs -L HOME /dev/$homedisk
  fi
  if [[ "$UEFI" != "yes" ]]; then
    mkfs.btrfs -L BOOT /dev/$bootdisk
  fi
fi

clear
echo "Now mount partions (automatic)"
sleep 1
mount /dev/disk/by-label/ROOT /mnt
mkdir /mnt/boot
if [[ "$HOMEIS" == "yes" ]]; then
  mkdir /mnt/home
  mount /dev/disk/by-label/HOME /mnt/home
fi
if [[ "$UEFI" == "yes" ]]; then
  mkdir /mnt/boot/efi
  mount /dev/disk/by-label/ESP /mnt/boot/efi
fi
if [[ "$UEFI" == "no" ]]; then
 mount /dev/disk/by-label/BOOT /mnt/boot
fi
clear

echo "Checking ethernet/wifi connection"
while ! ping -c3 artixlinux.org; do
  echo "You are not connected, CTRL+D when connect"
  connmanctl
done

echo -e "\nConnection is OK"
sleep 1
clear

while [[ "$initsystem" != "dinit" && "$initsystem" != "openrc" && "$initsystem" != "runit" && "$initsystem" != "s6"   ]]; do
read -p "Choose initialisation system (dinit, openrc, runit, s6) " initsystem
done

case $initsystem in 
  dinit)
    echo "dinit"
    dinitctl start ntpd
    ;;
  openrc)
    echo "openrc"
    rc-service ntpd start
    ;;
  runit)
    echo "runit"
    sv up ntpd
    ;;
  s6)
    echo "s6"
    s6-rc -u change ntpd
    ;;
esac

pacman-key --init
pacman-key --populate artix
pacman -Syu

case $initsystem in 
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

while [[ "$likernel" != "default" && "$likernel" != "zen" && "$likernel" != "lts" && "$likernel" != "rt" && "$likernel" != "rt-lts" && "$likernel" != "ck" ]]; do
read -p "Choose Linux kernel (lts, zen, default, rt, rt-lts, ck)" likernel
done
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
cat > /mnt/vars.sh <<EOF
export osprober="$osprober"
export UEFI="$UEFI"
export disk="$disk"
export initsystem="$initsystem"
export userneed="$userneed"
export username="$username"
export dhcpclient="$dhcpclient"
export networkin="$networkin"
export bluetooth="$bluetooth"
export wireless="$wireless"
export texteditor="$texteditor"
export localename="$localename"
EOF

artix-chroot /mnt

