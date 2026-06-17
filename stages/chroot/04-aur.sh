#!/usr/bin/env bash

install_paru() {
    local build_dir

    if command -v paru >/dev/null 2>&1; then
        return 0
    fi

    build_dir="$(mktemp -d /tmp/custarch-paru.XXXXXX)"
    chown "$USERNAME:$USERNAME" "$build_dir"

    log "Building paru-bin from AUR..."
    runuser -u "$USERNAME" -- git clone https://aur.archlinux.org/paru-bin.git "$build_dir"
    runuser -u "$USERNAME" -- bash -lc "cd '$build_dir' && makepkg -si --noconfirm"
}

install_aur_packages() {
    ((${#AUR_PACKAGES[@]} > 0)) || return 0

    log "Installing AUR packages..."
    runuser -u "$USERNAME" -- paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"
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

    install_paru
    install_aur_packages
    cleanup_aur_sudoers
    trap - EXIT
fi
