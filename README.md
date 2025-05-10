# artix-install
## This script will help you install artix linux.
The script first asks the questions and then automatically sets according to your criteria

## It will set up
* Init sysem(dinit, openrc, runit, s6)
* Kernel(if it has in repositories)
* Filesystem(Only btrfs or ext4)
* Network manager, wireless daemon, bluetooth, dhcpclient, texteditor(The script doesn't add them to autorun, add them yourself after installation)
* Automatically detects BIOS or UEFI you have
* And other
## It won't set
* DE or WM
* Other users(It will set only root user and password for it)
* All sorts of additional improvements
# After install your artix will like this
  ![image](https://github.com/user-attachments/assets/76c2de86-f562-47b0-8d05-8f58cae0dfa2)

## **If you plan to clone repositories from github, you will need to download git**
```
$ pacman -Sy
$ pacman -S git
$ git clone https://github.com/llovenya/artix-install.git
```

**When you have the artix-install directory, run these commands, and answer the following questions**
```
$ cd artix-install
$ chmod +x start.sh
$ ./start.sh
```
> The script will be improved in the future
