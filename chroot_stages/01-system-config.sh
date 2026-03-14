#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

PACMAN_CONF="/etc/pacman.conf"

sed -i 's/^#Color$/Color/' "$PACMAN_CONF"
sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' "$PACMAN_CONF"

ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#ru_RU.UTF-8 UTF-8$/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$HOSTNAME" > /etc/hostname

systemctl enable NetworkManager
systemctl enable reflector.timer


if [ "$VM" ]; then
    systemctl enable sshd
    systemctl start sshd
fi
