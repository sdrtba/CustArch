#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

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
