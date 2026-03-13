#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

reflector -c Russia -a 12 --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt \
    base base-devel linux linux-firmware amd-ucode \
    grub efibootmgr os-prober grub-btrfs btrfs-progs zram-generator \
    sudo networkmanager nano vim curl git

if [[ "$VM" == "VBOX" ]]; then
    pacman -S virtualbox-guest-utils linux-headers
    systemctl enable vboxservice
elif [[ "$VM" == "VMWare" ]]; then
    pacman -S open-vm-tools
    systemctl enable vmtoolsd
fi

genfstab -U /mnt >> /mnt/etc/fstab
