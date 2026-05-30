#!/usr/bin/env bash
set -Eeuo pipefail

prepare() {
    ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    source "$ROOT_DIR/lib/paths.sh"
    source "$LIB_DIR/common.sh"
    load_config

    exec > >(tee -a "$LOG_FILE") 2>&1

    if [[ "$(id -un)" != "$USERNAME" ]]; then
        die "Run this script as $USERNAME"
    fi
}

create_pre_postinstall_snapshot() {
    local snapshot_name

    if [[ "$FS_TYPE" != "btrfs" ]]; then
        log "Root filesystem is ${FS_TYPE:-unknown}, skipping pre-postinstall snapshot."
        return 0
    fi

    snapshot_name="pre-postinstall-$(date +%Y%m%d-%H%M%S)"

    sudo timeshift --create --comments "$snapshot_name"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    log "Snapshot created"
}

main() {
    local -a root_scripts user_scripts
    local root_script user_script stage_name

    prepare

    mapfile -t root_scripts < <(find "$POST_ROOT_DIR" -maxdepth 1 -type f -name '*.sh' | sort)
    mapfile -t user_scripts < <(find "$POST_USER_DIR" -maxdepth 1 -type f -name '*.sh' | sort)

    create_pre_postinstall_snapshot

    log "Running ${#root_scripts[@]} ROOT post-install stage(s)..."
    for root_script in "${root_scripts[@]}"; do
        stage_name="$(basename "$root_script")"
        log "Running root stage $stage_name..."
        sudo ROOT_DIR="$ROOT_DIR" bash "$root_script"
    done

    log "Running ${#user_scripts[@]} USER post-install stage(s)..."
    for user_script in "${user_scripts[@]}"; do
        stage_name="$(basename "$user_script")"
        log "Running user stage $stage_name..."
        bash "$user_script"
    done
}

main "$@"
