#!/usr/bin/env bash

sign_efi_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        sbctl sign -s "$file"
    else
        warn "EFI file not found, skipping Secure Boot signature: $file"
    fi
}

mountpoint -q /boot || die "/boot is not mounted."

log "Refreshing unified kernel image..."
mkinitcpio -P

if command -v sbctl >/dev/null 2>&1 && [[ -d /var/lib/sbctl/keys ]]; then
    log "Refreshing Secure Boot signatures..."
    sign_efi_file /boot/EFI/systemd/systemd-bootx64.efi
    sign_efi_file /boot/EFI/BOOT/BOOTX64.EFI
    sign_efi_file /boot/EFI/Linux/arch-linux.efi
else
    warn "sbctl keys are not available, skipping Secure Boot signatures."
fi
