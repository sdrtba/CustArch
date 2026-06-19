#!/usr/bin/env bash

uki_file="/boot/EFI/Linux/arch-linux.efi"

log "Verifying boot setup..."

mountpoint -q /boot || die "/boot is not mounted."
[[ -f "$uki_file" ]] || die "UKI file not found: $uki_file"

if bootctl --esp-path=/boot status; then
    log "systemd-boot status check passed."
else
    warn "systemd-boot status check failed."
fi

if command -v sbctl >/dev/null 2>&1; then
    if sbctl verify; then
        log "Secure Boot signature verification passed."
    else
        warn "Secure Boot signature verification reported unsigned files."
    fi

    warn "If Secure Boot is still disabled, enroll keys in firmware Setup Mode with: sbctl enroll-keys --microsoft"
else
    warn "sbctl is not installed, skipping Secure Boot verification."
fi
