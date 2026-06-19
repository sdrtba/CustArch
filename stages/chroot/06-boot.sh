#!/usr/bin/env bash

sign_efi_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        sbctl sign -s "$file"
    else
        warn "File not found, skipping Secure Boot signature: $file"
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

clear_efi_variable_immutable_flags() {
    local var
    local -a patterns=(
        /sys/firmware/efi/efivars/PK-*
        /sys/firmware/efi/efivars/KEK-*
        /sys/firmware/efi/efivars/db-*
        /sys/firmware/efi/efivars/dbx-*
    )

    for var in "${patterns[@]}"; do
        [[ -e "$var" ]] || continue
        chattr -i "$var" 2>/dev/null || warn "Could not clear immutable flag: $var"
    done
}

[[ -n "$ROOT_UUID" ]] || die "ROOT_UUID is not set."
mountpoint -q /boot || die "/boot is not mounted."

log "Installing systemd-boot..."
bootctl --esp-path=/boot install

mkdir -p /boot/EFI/Linux
printf 'root=UUID=%s rootflags=subvol=@ rw\n' "$ROOT_UUID" > /etc/kernel/cmdline

log "Ensuring btrfs is available in initramfs..."
ensure_mkinitcpio_module btrfs

cat > /etc/mkinitcpio.d/linux.preset <<'EOF'
ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"

PRESETS=('default' 'fallback')

default_uki="/boot/EFI/Linux/arch-linux.efi"
fallback_uki="/boot/EFI/Linux/arch-linux-fallback.efi"
fallback_options="-S autodetect"
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
sign_efi_file /boot/EFI/Linux/arch-linux-fallback.efi
sign_efi_file /boot/vmlinuz-linux

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
Depends = sbctl
Exec = /usr/bin/sbctl sign-all
EOF

log "Checking Secure Boot enrollment state..."
if ! sbctl_status="$(sbctl status 2>&1)"; then
    warn "Could not read sbctl status:"
    printf '%s\n' "$sbctl_status"
    return 0
fi

if ! grep -Eq '^Setup Mode:[[:space:]].*Enabled' <<<"$sbctl_status"; then
    warn "Firmware is not in Setup Mode, skipping Secure Boot key enrollment."
    warn "To enroll later: enter firmware Setup Mode and run sbctl enroll-keys --microsoft."
    return 0
fi

log "Clearing immutable flags on Secure Boot EFI variables..."
clear_efi_variable_immutable_flags

log "Enrolling Secure Boot keys with Microsoft certificates..."
if sbctl enroll-keys --microsoft; then
    sbctl status
else
    warn "Secure Boot key enrollment failed."
    warn "If EFI variables are immutable, clear them manually and retry: sbctl enroll-keys --microsoft"
fi
