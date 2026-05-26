#!/usr/bin/env bash
set -Eeuo pipefail

load_profile_file() {
    local profile_file="$1"

    if [[ ! -f "$profile_file" ]]; then
        die "[!] Missing profile: $profile_file"
    fi

    source "$profile_file"
}

load_install_profiles() {
    local profile_dir="$ROOT_DIR/profiles"

    BASE_PROFILE="${BASE_PROFILE:-base}"
    HARDWARE_PROFILE="${HARDWARE_PROFILE:-amd}"
    DESKTOP_PROFILE="${DESKTOP_PROFILE:-hyprland}"
    USER_PROFILE="${USER_PROFILE:-default}"

    # shellcheck disable=SC2034
    BASE_PACKAGES=()
    # shellcheck disable=SC2034
    HARDWARE_BOOT_PACKAGES=()
    # shellcheck disable=SC2034
    HARDWARE_PACKAGES=()
    # shellcheck disable=SC2034
    DESKTOP_PACKAGES=()
    # shellcheck disable=SC2034
    AUR_PACKAGES=()

    load_profile_file "$profile_dir/base/$BASE_PROFILE.sh"
    load_profile_file "$profile_dir/hardware/$HARDWARE_PROFILE.sh"
    load_profile_file "$profile_dir/desktop/$DESKTOP_PROFILE.sh"
    load_profile_file "$profile_dir/user/$USER_PROFILE.sh"
}
