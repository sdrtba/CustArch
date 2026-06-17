#!/usr/bin/env bash

[[ -n "$ROOT_UUID" ]] || die "ROOT_UUID is not set."
mountpoint -q /boot || die "/boot is not mounted."

log "Installing systemd-boot..."
bootctl --esp-path=/boot install

mkdir -p /boot/EFI/Linux
printf 'root=UUID=%s rootflags=subvol=@ rw\n' "$ROOT_UUID" > /etc/kernel/cmdline

cat > /etc/mkinitcpio.d/linux.preset <<'EOF'
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"

PRESETS=('default')

default_uki="/boot/EFI/Linux/arch-linux.efi"
EOF

cat > /boot/loader/loader.conf <<'EOF'
timeout 3
console-mode max
editor no
EOF

log "Building unified kernel image..."
mkinitcpio -P
