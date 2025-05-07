#!/usr/bin/bash
source vars.sh

#Auto partition
if [[ "$SWAP" == "yes" ]]; then
  mkswap -L SWAP "/dev/$swapdisk"
fi

if [[ "$filesystem" == "ext4" ]]; then
  mkfs.ext4 -L ROOT /dev/$rootdisk
  if [[ "$HOMEIS" == "yes" ]]; then
  mkfs.ext4 -L HOME /dev/$homedisk
  fi
  if [[ "$boot" == "BIOS" ]]; then
  mkfs.ext4 -L BOOT /dev/$bootdisk
  fi
fi

if [[ "$filesystem" == "btrfs" ]]; then
  mkfs.btrfs -L ROOT /dev/$rootdisk
  if [[ "$HOMEIS" == "yes" ]]; then
  mkfs.btrfs -L HOME /dev/$homedisk
  fi
  if [[ "$boot" == "BIOS" ]]; then
    mkfs.btrfs -L BOOT /dev/$bootdisk
  fi
fi
if [[ "$boot" == "UEFI" ]]; then
  mkfs.fat -F 32 "/dev/$bootdisk"
  fatlabel "/dev/$bootdisk" ESP
fi
mount /dev/disk/by-label/ROOT /mnt
mkdir -p /mnt/boot

if [[ "$HOMEIS" == "yes" ]]; then
  mkdir -p /mnt/home
  mount /dev/disk/by-label/HOME /mnt/home
fi
if [[ "$boot" == "UEFI" ]]; then
  mkdir -p /mnt/boot/efi
  mount /dev/disk/by-label/ESP /mnt/boot/efi
fi
if [[ "$boot" == "BIOS" ]]; then
 mount /dev/disk/by-label/BOOT /mnt/boot
fi

# init and kernel
basestrap --noconfirm /mnt base base-devel $usrchooseinit elogind-$usrchooseinit

if [[ "$likernel" != "default" ]]; then
  basestrap --noconfirm /mnt linux-$likernel linux-firmware
else
  basestrap --noconfirm /mnt linux linux-firmware
fi

fstabgen -U /mnt > /mnt/etc/fstab

#locale timezone
ln -sf /usr/share/zoneinfo/$localetime /mnt/etc/localtime
basestrap --noconfirm /mnt $texteditor
cp -f /etc/locale.gen /mnt/etc/locale.gen
artix-chroot /mnt locale-gen
echo "LANG=$locale" >> /mnt/etc/environment
echo "LC_COLLATE=C" >> /mnt/etc/environment
#grub
basestrap --noconfirm /mnt grub efibootmgr
if [[ "$osprober" == "yes" ]]; then
  basestrap --noconfirm /mnt os-prober
fi

if [[ "$boot" == "UEFI" ]]; then
   artix-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
 else
   artix-chroot /mnt grub-install --recheck /dev/$disk
fi
artix-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "$hostname" > /mnt/etc/hostname
if [[ "$usrchooseinit" == "openrc" ]]; then
  echo "hostname='$hostname'" > /mnt/etc/conf.d/hostname
fi
echo -e "# Static table lookup for hostnames.\n# See hosts(5) for details.\n127.0.0.1		localhost\n::1			localhost\n127.0.0.1		"$hostname".localdomain	"$hostname"" > /mnt/etc/hosts

if [[ "$dhcpclient" == "dhcpcd" ]]; then
  basestrap --noconfirm /mnt dhcpcd
elif [[ "$dhcpclient" == "dhclient" ]]; then
  basestrap --noconfirm /mnt dhclient
fi
if [[ "$networkin" != "none" ]]; then
  basestrap --noconfirm $networkin $networkin-$usrchooseinit
fi
if [[ "$bluetooth" == "yes" ]]; then
  basestrap --noconfirm bluez bluez-$usrchooseinit
fi
if [[ "$wireless" != "none" ]]; then
  basestrap --noconfirm $wireless $wireless-$usrchooseinit
fi
clear
cp vars.sh /mnt/root/


