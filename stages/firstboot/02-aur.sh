#!/usr/bin/env bash

install_paru() {
    local build_dir

    if command -v paru >/dev/null 2>&1; then
        return 0
    fi

    pacman -S --needed --noconfirm rustup ||
        die "Failed to install paru build dependencies."

    runuser -u "$USERNAME" -- rustup default stable ||
        die "Failed to initialize rustup for $USERNAME."

    build_dir="$(mktemp -d /tmp/custarch-paru.XXXXXX)" ||
        die "Failed to create temporary paru build directory."

    chown "$USERNAME:$USERNAME" "$build_dir" ||
        die "Failed to chown paru build directory."

    log "Building paru from AUR..."

    runuser -u "$USERNAME" -- git clone https://aur.archlinux.org/paru.git "$build_dir" ||
        { rm -rf -- "$build_dir"; return 1; }

    runuser -u "$USERNAME" -- bash -c 'cd "$1" && makepkg -si --noconfirm' _ "$build_dir" ||
        { rm -rf -- "$build_dir"; return 1; }

    rm -rf -- "$build_dir"
}

install_aur_packages() {
    local package
    local -a failed_packages=()

    log "Installing AUR packages..."
    for package in "${AUR_PACKAGES[@]}"; do
        log "Installing AUR package: $package"

        if ! runuser -u "$USERNAME" -- bash -lc \
            "paru -S --needed --noconfirm --skipreview --removemake '$package'"; then
            warn "AUR package installation failed: $package"
            failed_packages+=("$package")
        fi
    done

    if ((${#failed_packages[@]} > 0)); then
        warn "Some AUR packages were not installed: ${failed_packages[*]}"
        warn "Continuing firstboot; install them manually after setup completes."
    fi
}

cleanup_aur_sudoers() {
    rm -f "$sudoers_file"
}

[[ -n "$USERNAME" ]] || die "USERNAME is not set."
id "$USERNAME" >/dev/null 2>&1 || die "User does not exist: $USERNAME"

sudoers_file="/etc/sudoers.d/custarch-aur"
printf '%s ALL=(ALL:ALL) NOPASSWD: /usr/bin/pacman\n' "$USERNAME" > "$sudoers_file"
chmod 0440 "$sudoers_file"
trap cleanup_aur_sudoers EXIT

if install_paru; then
    install_aur_packages
else
    warn "paru installation failed. Skipping AUR packages."
fi

cleanup_aur_sudoers
trap - EXIT
