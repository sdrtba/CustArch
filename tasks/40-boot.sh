#!/usr/bin/env bash

boot_ensure_mkinitcpio_module() {
    local module="$1"
    local config="/etc/mkinitcpio.conf"

    require_file "$config"

    if grep -Eq "^[[:space:]]*MODULES=\\([^#]*\\b${module}\\b" "$config"; then
        return 0
    fi

    if grep -Eq "^[[:space:]]*MODULES=\\(" "$config"; then
        sed -i -E "/^[[:space:]]*MODULES=\\(/ s/\\(([^)]*)\\)/(\\1 ${module})/" "$config"
    else
        printf 'MODULES=(%s)\n' "$module" >> "$config"
    fi
}

run_chroot() {
    local root_partuuid root_options

    bootctl --esp-path=/boot install

    root_partuuid="$(blkid -s PARTUUID -o value "$ROOT_PART")"
    [[ -n "$root_partuuid" ]] || die "Could not resolve PARTUUID for $ROOT_PART"

    install_template linux.preset /etc/mkinitcpio.d/linux.preset
    install_template loader.conf /boot/loader/loader.conf
    mkdir -p /boot/EFI/Linux

    root_options="root=PARTUUID=$root_partuuid rw"
    if [[ "$FS_TYPE" == "btrfs" ]]; then
        root_options+=" rootflags=subvol=@"
    fi
    printf '%s\n' "$root_options" > /etc/kernel/cmdline

    if [[ "$FS_TYPE" == "btrfs" ]]; then
        boot_ensure_mkinitcpio_module btrfs
    fi

    mkinitcpio -P
}
