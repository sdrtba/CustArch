#!/usr/bin/env bash

[[ -n "$ROOT_UUID" ]] || die "ROOT_UUID is not set."
mountpoint -q /boot || die "/boot is not mounted."

sign_efi_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        sbctl sign -s "$file"
    else
        warn "EFI file not found, skipping Secure Boot signature: $file"
    fi
}

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
timeout 5
console-mode max
editor no
EOF

log "Building unified kernel image..."
mkinitcpio -P

log "Preparing Secure Boot signatures..."
if [[ ! -d /var/lib/sbctl/keys ]]; then
    sbctl create-keys
fi

sign_efi_file /boot/EFI/systemd/systemd-bootx64.efi
sign_efi_file /boot/EFI/BOOT/BOOTX64.EFI
sign_efi_file /boot/EFI/Linux/arch-linux.efi

warn "Secure Boot files are signed. Enroll keys with sbctl enroll-keys -m when the firmware is in Setup Mode."
