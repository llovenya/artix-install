#!/bin/bash
source vars.sh
localetime=""
osprober=""
userneed=""
hostname=""
networkin=""
dhcpclient=""
bluetooth=""
locale=""
ln -sf $localtime /etc/localtime
hwclock --systohc
#read -p "Choose your text editor: vim, nano, vi ... " texteditor
pacman -S --noconfirm $texteditor
$texteditor /etc/locale.gen
locale-gen
locale=$(grep -Ev '^\s*(#|$)' /etc/locale.gen | head -n 1 | awk '{print $1}')
export LANG="$locale"
export LC_COLLATE="C"

#read -p "dualboot? yes/no " osprober

pacman -S --noconfirm grub efibootmgr
if [[ "$osprober" == "yes" ]]; then
  pacman -S --noconfirm os-prober
fi

if [[ "$boot" == "UEFI" ]]; then
   grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub
 else
   grub-install --recheck /dev/$disk
fi

grub-mkconfig -o /boot/grub/grub.cfg

# echo "Now set root password"
# passwd
#read -p "User needed? yes/no" userneed

 if [[ "$userneed" == "yes" ]]; then
  read -p "username" username
  useradd -m $username
  echo "Password for your user"
  passwd $username
 fi

#read -p "hostname"
echo "$hostname" > /etc/hostname

if [[ "$initsystem" == "openrc" ]]; then
  echo "hostname='$hostname'" > /etc/conf.d/hostname
fi

echo -e "# Static table lookup for hostnames.\n# See hosts(5) for details.\n127.0.0.1		localhost\n::1			localhost\n127.0.0.1		"$hostname".localdomain	"$hostname"" > /etc/hosts

#read -p "dhcpd client? dhcpcd dhclient none "
if [[ "$dhcpclient" == "dhcpcd" ]]; then
  pacman -S --noconfirm dhcpcd
elif [[ "$dhcpclient" == "dhclient" ]]; then
  pacman -S --noconfirm dhclient
fi

#read -p "connman, networkmanager, none? " networkin

if [[ "$networkin" != "none" ]]; then
  pacman -S --noconfirm $networkin $networkin-$usrchooseinit
fi

#echo "After install add to autostart by your init system"

#read -p "Bluetooth yes/no " bluetooth
if [[ "$bluetooth" == "yes" ]]; then
  pacman -S --noconfirm bluez bluez-$usrchoseeinit
fi

#read -p "Wireless wpa_supplicant, iwd, none " wireless
if [[ "$wireless" != "none" ]]; then
pacman -S --noconfirm $wireless $wireless-$usrchooseinit
fi

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

update_var localetime "$localetime"
update_var osprober "$osprober"
update_var userneed "$userneed"
update_var hostname "$hostname"
update_var networkin "$networkin"
update_var dhcpclient "$dhcpclient"
update_var bluetooth "$bluetooth"
update_var locale "$locale"
