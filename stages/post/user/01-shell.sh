#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config
source "$LIB_DIR/profiles.sh"
load_install_profiles

if command -v paru >/dev/null 2>&1; then
    echo "[*] paru is already installed."
else
    build_dir="$(mktemp -d /tmp/paru.XXXXXX)"
    trap 'rm -rf "$build_dir"' EXIT

    git clone https://aur.archlinux.org/paru.git "$build_dir"
    cd "$build_dir"
    rustup default stable
    makepkg -si --noconfirm
fi

if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
    paru -Syu --noconfirm --needed "${AUR_PACKAGES[@]}"
fi
