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
clear
printf '\n%s\n' "$ansi_art"

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPT_DIR="$ROOT_DIR"
STAGES_DIR=$ROOT_DIR/stages
LIVE_DIR=$STAGES_DIR/live
CHROOT_DIR=$STAGES_DIR/chroot
POST_DIR=$STAGES_DIR/post
LIB_DIR=$ROOT_DIR/lib
CONFIG_FILE=$ROOT_DIR/settings.conf
LOG_FILE=$ROOT_DIR/install.log
export ROOT_DIR SCRIPT_DIR STAGES_DIR LIVE_DIR CHROOT_DIR POST_DIR LIB_DIR CONFIG_FILE LOG_FILE

exec > >(tee -a "$LOG_FILE") 2>&1

source "$LIB_DIR/common.sh"
load_config
require_root

mapfile -t stage_scripts < <(find "$LIVE_DIR" -maxdepth 1 -type f -name '*.sh' | sort)
log "Running ${#stage_scripts[@]} stage(s)..."
for stage_script in "${stage_scripts[@]}"; do
    stage_name="$(basename "$stage_script")"
    log "Running $stage_name..."
    bash "$stage_script"
done

log "Installation stages finished."
log "Reboot and start postinstall.sh to complete the installation."
