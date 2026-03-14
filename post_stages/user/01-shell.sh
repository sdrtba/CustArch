#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

if command -v paru >/dev/null 2>&1; then
    echo "[*] paru is already installed, skipping."
    exit 0
fi

build_dir="$(mktemp -d /tmp/paru.XXXXXX)"
trap 'rm -rf "$build_dir"' EXIT

git clone https://aur.archlinux.org/paru.git "$build_dir"
cd "$build_dir"
rustup default stable
makepkg -si --noconfirm

paru -Syu --needed --noconfirm lxqt-policykit
