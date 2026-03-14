#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

reflector -c Russia -a 12 --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

packages=(
    base base-devel linux linux-firmware amd-ucode
    grub efibootmgr os-prober grub-btrfs btrfs-progs zram-generator
    sudo networkmanager nano vim curl git reflector timeshift
)

case "$VM" in
    VBOX)
        packages+=(openssh virtualbox-guest-utils linux-headers)
        ;;
    VMWare)
        packages+=(openssh open-vm-tools)
        ;;
esac

pacstrap -K /mnt \
    "${packages[@]}"

genfstab -U /mnt >> /mnt/etc/fstab
