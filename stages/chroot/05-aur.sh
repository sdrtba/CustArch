#!/usr/bin/env bash

install_paru() {
    local build_dir

    if command -v paru >/dev/null 2>&1; then
        return 0
    fi

    build_dir="$(mktemp -d /tmp/custarch-paru.XXXXXX)"
    chown "$USERNAME:$USERNAME" "$build_dir"

    log "Building paru-bin from AUR..."
    runuser -u "$USERNAME" -- git clone https://aur.archlinux.org/paru-bin.git "$build_dir" ||
        return 1
    runuser -u "$USERNAME" -- bash -lc "cd '$build_dir' && makepkg -si --noconfirm" ||
        return 1
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
        warn "Continuing installation; install them manually after first boot."
    fi
}

cleanup_aur_sudoers() {
    rm -f "$sudoers_file"
}

sudoers_file="/etc/sudoers.d/custarch-aur"

[[ -n "$USERNAME" ]] || die "USERNAME is not set."
id "$USERNAME" >/dev/null 2>&1 || die "User does not exist: $USERNAME"

if ((${#AUR_PACKAGES[@]} == 0)); then
    log "No AUR packages configured."
else
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
fi
