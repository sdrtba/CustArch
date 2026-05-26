#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root
source "$LIB_DIR/profiles.sh"
load_install_profiles

packages=(
    "${HARDWARE_PACKAGES[@]}"
    "${DESKTOP_PACKAGES[@]}"
)

if [[ ${#packages[@]} -gt 0 ]]; then
    pacman_install "${packages[@]}"
fi
