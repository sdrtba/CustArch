#!/usr/bin/env bash
set -Eeuo pipefail

ansi_art='                           ▄▄▄
 ▄███████  ███   ███   ▄███████  ▄███████████▄   ▄███████    ▄███████   ▄███████    ▄█   █▄
███   ███  ███   ███  ███             ███       ███   ███   ███   ███  ███   ███   ███   ███
███   █▀   ███   ███  ███             ███       ███   ███   ███   ███  ███   █▀    ███   ███
███        ███   ███  ▀███████▄       ███      ▄███▄▄▄███  ▄███▄▄▄██▀  ███        ▄███▄▄▄███▄
███        ███   ███        ███       ███      ▀███▀▀▀███  ▀███▀▀▀▀    ███       ▀▀███▀▀▀███
███   █▄   ███   ███        ███       ███       ███   ███  ██████████  ███   █▄    ███   ███
███   ███  ███   ███        ███       ███       ███   ███   ███   ███  ███   ███   ███   ███
███████▀    ▀█████▀    ▀█████▀        ███       ███   █▀    ███   ███  ███████▀    ███   █▀
                                                            ███   █▀                         '

prepare() {
    clear
    printf '\n%s\n' "$ansi_art"

    ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    source "$ROOT_DIR/lib/paths.sh"
    source "$LIB_DIR/common.sh"
    load_config
    require_root

    exec > >(tee -a "$LOG_FILE") 2>&1
}

finish() {
    if mountpoint -q /mnt; then
        umount -R /mnt
    else
        warn "/mnt is not mounted, skipping unmount."
    fi

    read -rp "Reboot now? [y/N]: " REBOOT_CONFIRM
    if [[ "$REBOOT_CONFIRM" =~ ^[Yy]$ ]]; then
        reboot
    fi
}

main() {
    prepare

    mapfile -t stage_scripts < <(find "$LIVE_DIR" -maxdepth 1 -type f -name '*.sh' | sort)
    log "Running ${#stage_scripts[@]} stage(s)..."
    for stage_script in "${stage_scripts[@]}"; do
        stage_name="$(basename "$stage_script")"
        log "Running $stage_name..."
        bash "$stage_script"
    done

    log "Installation stages finished."
    log "Reboot and start postinstall.sh to complete the installation."

    finish
}

main "$@"
