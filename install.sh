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
    if command -v git >/dev/null 2>&1; then
        return 0
    fi

    log "Installing git..."
    pacman -Sy --needed --noconfirm git
}

is_repo_dir() {
    local repo_dir="$1"

    [[ -f "$repo_dir/start.sh" ]] &&
        [[ -f "$repo_dir/initial.conf" ]] &&
        [[ -d "$repo_dir/lib" ]] &&
        [[ -d "$repo_dir/stages" ]]
}

resolve_repo_dir() {
    local script_dir

    script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

    if is_repo_dir "$script_dir"; then
        printf '%s\n' "$script_dir"
        return 0
    fi

    if [[ -e "$TARGET_DIR" ]]; then
        is_repo_dir "$TARGET_DIR" ||
            die "$TARGET_DIR exists but is not a CustArch repository."
        printf '%s\n' "$TARGET_DIR"
        return 0
    fi

    ensure_git

    log "Cloning repository: $REPO_URL"
    git clone "$REPO_URL" "$TARGET_DIR"
    printf '%s\n' "$TARGET_DIR"
}

main() {
    local repo_dir

    require_arch_iso
    require_network

    repo_dir="$(resolve_repo_dir)"
    log "Starting LIVE phase from: $repo_dir"
    cd "$repo_dir"
    exec ./start.sh live
}

main "$@"
