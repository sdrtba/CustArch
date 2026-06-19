#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/sdrtba/CustArch.git"
TARGET_DIR="/root/custarch"

log() {
    printf '[*] %s\n' "$*" >&2
}

die() {
    printf '[!] %s\n' "$*" >&2
    exit 1
}

require_arch_iso() {
    [[ -f /etc/arch-release ]] || die "This does not look like Arch Linux."
    [[ -d /run/archiso ]] || die "This script must run from the Arch Linux live ISO."
}

require_network() {
    ping -c 1 -W 3 github.com >/dev/null 2>&1 ||
        die "Network check failed. Connect to the network and rerun install.sh."
}

ensure_git() {
    command -v git >/dev/null 2>&1 && return 0
    log "Installing git..."
    pacman -Sy --needed --noconfirm git
}

is_repo_dir() {
    local repo_dir="$1"

    [[ -f "$repo_dir/start.sh" ]] &&
        [[ -f "$repo_dir/init.conf" ]] &&
        [[ -d "$repo_dir/lib" ]] &&
        [[ -d "$repo_dir/stages" ]]
}

resolve_repo_dir() {
    local script_dir

    script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

    if is_repo_dir "$script_dir"; then
        REPO_DIR="$script_dir"
        return 0
    fi

    if [[ -e "$TARGET_DIR" ]]; then
        is_repo_dir "$TARGET_DIR" ||
            die "$TARGET_DIR exists but is not a CustArch repository."
        REPO_DIR=$TARGET_DIR
        return 0
    fi

    ensure_git

    log "Cloning repository: $REPO_URL"
    git clone "$REPO_URL" "$TARGET_DIR"
    REPO_DIR="$TARGET_DIR"
}

main() {
    require_arch_iso
    require_network

    REPO_DIR=""
    resolve_repo_dir
    [[ -n "$REPO_DIR" ]] || die "Could not resolve repository directory."

    log "Starting LIVE phase from: $REPO_DIR"
    cd "$REPO_DIR"
    exec ./start.sh live
}

main "$@"
