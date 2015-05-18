#!/bin/bash
# Ubuntu Kernel Auto Update script
# Use at your own risk
# The kernel upgrade consists of 3 files:
# 1) linux-headers-….deb
# 2) linux-image-….deb
# 3) linux-headers-…_all.deb - which is common for all of the architectures
# DO NOT RUN THE dpkg COMMAND UNLESS YOU KNOW WHAT YOU ARE DOING!!!
# AND YOU ARE ABSOLUTELY SURE YOU HAVE ALL OF THESE FILES
# Don't forget to play safe :)
# Enjoy, Yaron.

# Get current date to name the folder
DIR=`date +"%y%m%d"`
# URL Prefix (used for listing and getting deb packages)
export URL_PREFIX=http://kernel.ubuntu.com/~kernel-ppa/mainline/daily/current/

# This menu is displayed if the CPU architecture is incorrect (upon user selection)
menu()
{
echo Please select from the following architectures:
# Getting the list of architectures available from the Ubuntu Kernel page
IFS=$'\r\n' && export options=(`curl -s $URL_PREFIX | awk -F"=\"|\">|G." '/BUILD\.LOG\../ && !/binary-headers/ {print $8}' | nl -w1 -s ") "`)
opt_length=${#options[@]}

unset REPLY
while [[ ! $REPLY =~ ^[1-$opt_length]$ ]]
do
for x in ${options[@]}
  do
    echo $x
  done
read -n 1 -r
if [[ ! $REPLY =~ ^[1-$opt_length]$ ]]; then
  echo -e "\nPlease reselect"
fi
done

echo -e "\nYou have selected ${options[${REPLY}-1]#* }"
export arch=${options[${REPLY}-1]#* }
}

export arch=$([ `uname -m` = x86_64 ] && echo amd64 || echo i386)
read -p "The script detected that your CPU type is $arch, is this correct? [Y/n] " -n 1 -r
REPLY=${REPLY,,}
if [[ $REPLY =~ ^(no|n)$ ]]
then
  menu
fi

# Creating a list of files to download based on user selection
LIST=(`curl -s $URL_PREFIX | awk -F"<|>" '/all\.deb/ || $0 ~ ENVIRON["arch"]".deb" && !/lowl/ {print ENVIRON["URL_PREFIX"]$13}'`)
mkdir -p ~/Downloads/linuxkernel/$DIR

wget ${LIST[@]} -P ~/Downloads/linuxkernel/$DIR

cd ~/Downloads/linuxkernel/$DIR

# Optional: Uncomment the following line if you want to autoinstall the packages.
#sudo dpkg -i ~/Downloads/linuxkernel/$DIR/*
