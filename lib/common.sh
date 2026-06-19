#!/usr/bin/env bash

log() {
    printf '[*] %s\n' "$*" >&2
}

warn() {
    printf '[!] %s\n' "$*" >&2
}

die() {
    printf '[!!!] %s\n' "$*" >&2
    exit 1
}

require_root() {
    (( EUID == 0 )) || die "This command must be run as root."
}

require_arch_iso() {
    [[ -f /etc/arch-release ]] || die "This does not look like Arch Linux."
    [[ -d /run/archiso ]] || die "This installer must run from the Arch Linux live ISO."
}

require_uefi() {
    [[ -d /sys/firmware/efi/efivars ]] || die "UEFI mode is required."
}

require_file() {
    local file="$1"
    [[ -f "$file" ]] || die "Required file not found: $file"
    [[ -r "$file" ]] || die "Required file is not readable: $file"
}

require_network() {
    ping -c 1 -W 3 github.com >/dev/null 2>&1 || die "Network check failed."
}

confirm_exact() {
    local prompt="$1"
    local expected="$2"
    local answer

    printf '%s\n' "$prompt" >/dev/tty
    printf 'Type exactly "%s" to continue: ' "$expected" >/dev/tty
    read -r answer </dev/tty
    [[ "$answer" == "$expected" ]] || die "Confirmation failed."
}

pacman_install() {
    local packages=("$@")
    ((${#packages[@]} > 0)) || return 0
    pacman -S --needed --noconfirm "${packages[@]}"
}

copy_self_to_target() {
    local target="$1"

    mkdir -p "$target"
    rsync -a --delete \
        --exclude '.git' \
        --exclude 'var' \
        "$SCRIPT_DIR/" "$target/"
}
