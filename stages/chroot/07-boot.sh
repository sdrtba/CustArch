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

ensure_mkinitcpio_module() {
    local module="$1"
    local config="/etc/mkinitcpio.conf"

    require_file "$config"

    if grep -Eq "^[[:space:]]*MODULES=\\([^#]*\\b${module}\\b" "$config"; then
        return 0
    fi

    if grep -Eq "^[[:space:]]*MODULES=\\(" "$config"; then
        sed -i -E "/^[[:space:]]*MODULES=\\(/ s/\\(([^)]*)\\)/(\\1 ${module})/" "$config"
    else
        printf 'MODULES=(%s)\n' "$module" >> "$config"
    fi
}

log "Installing systemd-boot..."
bootctl --esp-path=/boot install

mkdir -p /boot/EFI/Linux
printf 'root=UUID=%s rootflags=subvol=@ rw\n' "$ROOT_UUID" > /etc/kernel/cmdline

log "Ensuring btrfs is available in initramfs..."
ensure_mkinitcpio_module btrfs

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
auto-entries yes
auto-firmware yes
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

log "Generating pacman hook for auto sign..."
mkdir -p /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/99-secureboot-sign.hook <<'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = linux
Target = systemd
Target = mkinitcpio

[Action]
Description = Signing EFI binaries for Secure Boot...
When = PostTransaction
Exec = /usr/bin/sbctl sign-all
EOF

log "Current status of sbctl..."
sbctl verify

warn "Secure Boot files are signed. Enroll keys with sbctl enroll-keys --microsoft when the firmware is in Setup Mode."
