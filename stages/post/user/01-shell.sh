#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/paths.sh"
source "$LIB_DIR/common.sh"
load_config
source "$LIB_DIR/packages.sh"

install_paru() {
    local build_dir

    if command -v paru >/dev/null 2>&1; then
        log "paru is already installed."
        return 0
    fi

    build_dir="$(mktemp -d /tmp/paru.XXXXXX)"

    (
        trap 'rm -rf "$build_dir"' EXIT
        git clone https://aur.archlinux.org/paru.git "$build_dir"
        cd "$build_dir"
        rustup default stable
        makepkg -si --noconfirm
    )
}

main() {
    install_paru

    if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
        paru -Syu --noconfirm --needed "${AUR_PACKAGES[@]}"
    fi
}

main "$@"
