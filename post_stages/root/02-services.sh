#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

ufw allow 22
systemctl enable ufw
systemctl start ufw
ufw --force enable

systemctl enable fstrim.timer

systemctl enable grub-btrfsd
grub-mkconfig -o /boot/grub/grub.cfg
