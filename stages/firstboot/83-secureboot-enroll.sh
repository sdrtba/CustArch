#!/usr/bin/env bash

clear_efi_variable_immutable_flags() {
    local var
    local -a patterns=(
        /sys/firmware/efi/efivars/PK-*
        /sys/firmware/efi/efivars/KEK-*
        /sys/firmware/efi/efivars/db-*
        /sys/firmware/efi/efivars/dbx-*
    )

    command -v chattr >/dev/null 2>&1 || {
        warn "chattr is not available, cannot clear immutable flags on EFI variables."
        return 0
    }

    for var in "${patterns[@]}"; do
        [[ -e "$var" ]] || continue
        chattr -i "$var" 2>/dev/null || warn "Could not clear immutable flag: $var"
    done
}

confirm_secureboot_enrollment() {
    local confirm

    warn "Firmware is in Secure Boot Setup Mode."
    warn "This can enroll CustArch Secure Boot keys into firmware NVRAM."
    warn "Microsoft keys will be preserved for Windows dual-boot."
    read -rp "Enroll Secure Boot keys now? Type 'YES' to continue: " confirm
    [[ "$confirm" == "YES" ]]
}

if ! command -v sbctl >/dev/null 2>&1; then
    warn "sbctl is not installed, skipping Secure Boot key enrollment."
    return 0
fi

if [[ ! -d /var/lib/sbctl/keys ]]; then
    warn "sbctl keys are not available, skipping Secure Boot key enrollment."
    return 0
fi

log "Checking Secure Boot enrollment state..."
if ! sbctl_status="$(sbctl status 2>&1)"; then
    warn "Could not read sbctl status:"
    printf '%s\n' "$sbctl_status"
    return 0
fi

printf '%s\n' "$sbctl_status"

if ! grep -Eq '^Setup Mode:[[:space:]].*Enabled' <<<"$sbctl_status"; then
    warn "Firmware is not in Setup Mode, skipping Secure Boot key enrollment."
    warn "To enroll later: enter firmware Setup Mode and run sbctl enroll-keys --microsoft."
    return 0
fi

if ! confirm_secureboot_enrollment; then
    warn "Secure Boot key enrollment skipped by user."
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
