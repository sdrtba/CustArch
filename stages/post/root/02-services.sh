#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

ufw allow 22
enable_service ufw
start_service ufw
ufw --force enable

enable_service fstrim.timer

if [[ "$FS_TYPE" = "btrfs" ]]; then
    enable_service grub-btrfsd
    grub-mkconfig -o /boot/grub/grub.cfg
fi

if command -v clash-verge >/dev/null 2>&1; then
    setcap cap_net_admin,cap_net_bind_service+ep "$(command -v clash-verge)"
else
    echo "[*] clash-verge not installed yet, skipping capabilities."
fi

enable_service nftables
