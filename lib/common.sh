#!/usr/bin/env bash

LOG_STARTED="${LOG_STARTED:-no}"
LOG_FILE="${LOG_FILE:-}"

start_logging() {
    local mode="$1"
    local log_dir timestamp

    [[ "$LOG_STARTED" == "no" ]] || return 0

    log_dir="${LOG_DIR:-/var/log/custarch}"
    timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
    LOG_FILE="${LOG_FILE:-$log_dir/$mode-$timestamp.log}"

    mkdir -p "$(dirname -- "$LOG_FILE")"
    exec > >(tee -a "$LOG_FILE") 2>&1

    LOG_STARTED="yes"
    export LOG_STARTED LOG_FILE
    log "Logging to $LOG_FILE"
}

log() {
    printf '[%(%Y-%m-%dT%H:%M:%SZ)T] [*] %s\n' -1 "$*" >&2
}

warn() {
    printf '[%(%Y-%m-%dT%H:%M:%SZ)T] [!] %s\n' -1 "$*" >&2
}

die() {
    printf '[%(%Y-%m-%dT%H:%M:%SZ)T] [!!!] %s\n' -1 "$*" >&2
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

install_template() {
    local source_name="$1"
    local target_path="$2"
    local source_path="$SCRIPT_DIR/templates/$source_name"

    [[ -r "$source_path" ]] || die "Template is not readable: $source_path"
    mkdir -p "$(dirname -- "$target_path")"
    install -m 0644 "$source_path" "$target_path"
}
