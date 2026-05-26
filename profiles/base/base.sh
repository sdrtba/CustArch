#!/usr/bin/env bash

BASE_PACKAGES=(
  base
  base-devel
  linux
  linux-firmware
  efibootmgr
  grub
  os-prober
  zram-generator
  sudo
  reflector
  networkmanager
  nano
  vim
  curl
  wget
  git
)

if [ "$FS_TYPE" = "btrfs" ]; then
  BASE_PACKAGES+=(grub-btrfs btrfs-progs timeshift)
fi
