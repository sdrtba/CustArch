#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

main() {
    local grub_defaults="/etc/default/grub"

    if grep -q '^#\?GRUB_DISABLE_OS_PROBER=' "$grub_defaults"; then
        sed -i 's/^#\?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$grub_defaults"
    else
        printf '\nGRUB_DISABLE_OS_PROBER=false\n' >> "$grub_defaults"
    fi

    grub-install \
        --target=x86_64-efi \
        --efi-directory=/efi \
        --bootloader-id=GRUB

    grub-mkconfig -o /boot/grub/grub.cfg

    cat > /etc/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF
}

main "$@"
