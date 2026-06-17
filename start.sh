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
    if [[ -t 1 ]]; then
        clear
    fi
    printf '\n%s\n' "$ansi_art"

    ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    LIB_DIR="$ROOT_DIR/lib"
    INITIAL_FILE="$ROOT_DIR/initial.conf"
    LOG_FILE="$ROOT_DIR/install.log"
    export ROOT_DIR LIB_DIR INITIAL_FILE LOG_FILE

    source "$LIB_DIR/common.sh"
    source "$LIB_DIR/state.sh"
    source "$LIB_DIR/packages.sh"

    require_root
    if [[ "$PHASE" == "live" ]]; then
        init_state
    fi
    load_state

    if [[ -r /dev/tty ]]; then
        exec </dev/tty
    fi

    exec > >(tee -a "$LOG_FILE") 2>&1
}

run_stages() {
    local -a stage_scripts
    local stage_script stage_name
    local stage_dir="$ROOT_DIR/stages/$PHASE"

    [[ -d "$stage_dir" ]] || die "Stage directory not found: $stage_dir"

    mapfile -t stage_scripts < <(find "$stage_dir" -maxdepth 1 -type f -name '*.sh' | sort)
    ((${#stage_scripts[@]} > 0)) || die "No stages found for phase: $PHASE"

    log "Running ${#stage_scripts[@]} ${PHASE} stage(s)..."
    for stage_script in "${stage_scripts[@]}"; do
        stage_name="${stage_script##*/}"
        log "Running $stage_name..."
        source "$stage_script"
    done
}

finish() {
    log "$PHASE phase finished."

    [[ "$PHASE" == "live" ]] || return 0

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
    PHASE="${1:-}"
    export PHASE

    case "$PHASE" in
        live|chroot|firstboot|user)
            ;;
        *)
            printf '[!] Usage: %s <live|chroot|firstboot|user>\n' "$0" >&2
            exit 1
            ;;
    esac

    prepare
    run_stages
    finish
}

main "$@"
