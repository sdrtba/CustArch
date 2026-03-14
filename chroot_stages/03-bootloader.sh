#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

GRUB_DEFAULTS="/etc/default/grub"

if grep -q '^#\?GRUB_DISABLE_OS_PROBER=' "$GRUB_DEFAULTS"; then
    sed -i 's/^#\?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$GRUB_DEFAULTS"
else
    printf '\nGRUB_DISABLE_OS_PROBER=false\n' >> "$GRUB_DEFAULTS"
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
