#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

VM="${VM:-}"

case "$VM" in
    VBOX)
        systemctl enable vboxservice
        ;;
    VMWare)
        systemctl enable vmtoolsd
        ;;
esac
