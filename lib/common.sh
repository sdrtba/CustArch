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

tui() {
    [[ -r /dev/tty && -w /dev/tty ]] ||
        die "No interactive terminal available."
    "$@" </dev/tty >/dev/tty 2>&1
}

require_root() {
    (( EUID == 0 )) || die "This stage must be run as root."
}

require_user() {
    local username="$1"

    [[ -n "$username" ]] || die "Username is not set."
    [[ "$(id -un)" == "$username" ]] || die "Run this phase as $username."
}

require_file() {
    local file="$1"
    [[ -f "$file" ]] || die "Required file not found: $file"
    [[ -r "$file" ]] || die "Required file is not readable: $file"
}

pacman_install() {
    local packages=("$@")
    ((${#packages[@]} > 0)) || return 0
    pacman -S --needed --noconfirm "${packages[@]}"
}

start_service() {
    local service="$1"
    if [[ -d /run/systemd/system ]]; then
        systemctl start "$service"
    else
        warn "systemd is not running, skipping service start: $service"
    fi
}
