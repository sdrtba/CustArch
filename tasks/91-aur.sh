#!/usr/bin/env bash

aur_install_paru() {
    local build_dir

    if command -v paru >/dev/null 2>&1; then
        return 0
    fi

    runuser -u "$USERNAME" -- rustup default stable ||
        die "Failed to initialize rustup for $USERNAME."

    build_dir="$(mktemp -d /tmp/custarch-paru.XXXXXX)" ||
        die "Failed to create temporary paru build directory."

    chown "$USERNAME:$USERNAME" "$build_dir" ||
        die "Failed to chown paru build directory."

    log "Building paru from AUR..."
    if ! runuser -u "$USERNAME" -- git clone https://aur.archlinux.org/paru.git "$build_dir"; then
        rm -rf -- "$build_dir"
        return 1
    fi

    # shellcheck disable=SC2016
    if ! runuser -u "$USERNAME" -- bash -c 'cd "$1" && makepkg -si --noconfirm' _ "$build_dir"; then
        rm -rf -- "$build_dir"
        return 1
    fi

    rm -rf -- "$build_dir"
}

aur_install_packages() {
    local package
    local -a failed_packages=()

    log "Installing AUR packages..."
    for package in "${AUR_PACKAGES[@]}"; do
        [[ "$package" != "paru" ]] || continue

        log "Installing AUR package: $package"
        # shellcheck disable=SC2016
        if ! runuser -u "$USERNAME" -- bash -lc \
            'paru -S --needed --noconfirm --skipreview --removemake "$1"' _ "$package"; then
            warn "AUR package installation failed: $package"
            failed_packages+=("$package")
        fi
    done

    if ((${#failed_packages[@]} > 0)); then
        warn "Some AUR packages were not installed: ${failed_packages[*]}"
    fi
}

aur_run_setup() {
    local sudoers_file="/etc/sudoers.d/custarch-aur"

    id "$USERNAME" >/dev/null 2>&1 || die "User does not exist: $USERNAME"

    printf '%s ALL=(ALL:ALL) NOPASSWD: /usr/bin/pacman\n' "$USERNAME" > "$sudoers_file"
    chmod 0440 "$sudoers_file"
    trap 'rm -f /etc/sudoers.d/custarch-aur' RETURN

    if aur_install_paru; then
        aur_install_packages
    else
        warn "paru installation failed. Skipping AUR packages."
    fi

    rm -f "$sudoers_file"
    trap - RETURN
}

run_post() {
    if [[ "$INSTALL_PARU" == "yes" ]]; then
        aur_run_setup
    fi
}
