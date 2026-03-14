#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

ufw allow 22
systemctl enable ufw
systemctl start ufw
ufw --force enable

sudo systemctl enable fstrim.timer

sudo systemctl enable grub-btrfsd
sudo grub-mkconfig -o /boot/grub/grub.cfg
