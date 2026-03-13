#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

arch-chroot /mnt /bin/bash -lc 'cd /root/CustArch && ./chroot/00-entry.sh'
