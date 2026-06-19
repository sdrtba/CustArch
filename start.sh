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
    ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    LIB_DIR="$ROOT_DIR/lib"
    INIT_FILE="$ROOT_DIR/init.conf"
    LOG_FILE="$ROOT_DIR/install.log"
    export ROOT_DIR LIB_DIR INIT_FILE LOG_FILE

    source "$LIB_DIR/common.sh"
    source "$LIB_DIR/state.sh"
    source "$LIB_DIR/packages.sh"

    case "$PHASE" in
        live)
            require_root
            init_state
            clear
            printf '\n%s\n' "$ansi_art"
            ;;
        chroot|firstboot)
            require_root
            ;;
    esac

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
}

main "$@"
