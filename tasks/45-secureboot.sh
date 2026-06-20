#!/usr/bin/env bash

secureboot_sign_efi_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        sbctl sign -s "$file"
    else
        warn "File not found, skipping Secure Boot signature: $file"
    fi
}

secureboot_clear_efi_variable_immutable_flags() {
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

run_chroot() {
    local sbctl_status

    install_template 99-secureboot-sign.hook /etc/pacman.d/hooks/99-secureboot-sign.hook

    if ! sbctl_status="$(sbctl status 2>&1)"; then
        warn "sbctl status failed; secure boot signing will need manual review."
        printf '%s\n' "$sbctl_status"
        return 0
    fi

    if ! grep -Eq '^Installed:[[:space:]].*(yes|✓)' <<<"$sbctl_status"; then
        sbctl create-keys
    fi

    secureboot_sign_efi_file /boot/EFI/systemd/systemd-bootx64.efi
    secureboot_sign_efi_file /boot/EFI/BOOT/BOOTX64.EFI
    secureboot_sign_efi_file /boot/EFI/Linux/arch-linux.efi
    secureboot_sign_efi_file /boot/EFI/Linux/arch-linux-fallback.efi
    secureboot_sign_efi_file /boot/vmlinuz-linux

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
    secureboot_clear_efi_variable_immutable_flags

    log "Enrolling Secure Boot keys with Microsoft certificates..."
    if sbctl enroll-keys --microsoft; then
        sbctl status
    else
        warn "Secure Boot key enrollment failed."
        warn "If EFI variables are immutable, clear them manually and retry: sbctl enroll-keys --microsoft"
    fi
}
