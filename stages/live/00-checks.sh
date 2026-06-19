#!/usr/bin/env bash

log "Checking live environment..."

[[ -f /etc/arch-release ]] || die "This does not look like Arch Linux."
[[ -d /run/archiso ]] || die "This script must run from the Arch Linux live ISO."
[[ -d /sys/firmware/efi/efivars ]] || die "UEFI mode is required."

ping -c 1 -W 3 github.com >/dev/null 2>&1 ||
    die "Network check failed."

log "Live environment is ready."
