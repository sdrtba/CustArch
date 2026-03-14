#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
POST_DIR="$SCRIPT_DIR/post_stages"
ROOT_DIR="$POST_DIR/root"
USER_DIR="$POST_DIR/user"
LIB_DIR="$SCRIPT_DIR/lib"
CONFIG_FILE="$SCRIPT_DIR/install.conf"
CONFIG_DIR="$SCRIPT_DIR/configs"
export SCRIPT_DIR POST_DIR ROOT_DIR USER_DIR LIB_DIR CONFIG_FILE CONFIG_DIR

source "$LIB_DIR/common.sh"
load_config

create_pre_postinstall_snapshot() {
    local snapshot_name

    if [[ "$FS_TYPE" != "btrfs" ]]; then
        echo "[*] Root filesystem is ${FS_TYPE:-unknown}, skipping pre-postinstall snapshot."
        return 0
    fi

    snapshot_name="pre-postinstall-$(date +%Y%m%d-%H%M%S)"

    sudo btrfs subvolume create --commnts "$snapshot_name" >/dev/null
    echo "[*] Snapshot created"
}

if [[ "$(id -un)" != "$USERNAME" ]]; then
    echo "[!] Run this script as $USERNAME"
    exit 1
fi

mapfile -t root_scripts < <(find "$ROOT_DIR" -maxdepth 1 -type f -name '*.sh' | sort)
mapfile -t user_scripts < <(find "$USER_DIR" -maxdepth 1 -type f -name '*.sh' | sort)

create_pre_postinstall_snapshot

echo "[*] Running ${#root_scripts[@]} ROOT post-install stage(s)..."
for root_script in "${root_scripts[@]}"; do
    stage_name="$(basename "$root_script")"
    echo "[*] Running root stage $stage_name..."
    sudo \
        SCRIPT_DIR="$SCRIPT_DIR" \
        POST_DIR="$POST_DIR" \
        ROOT_DIR="$ROOT_DIR" \
        USER_DIR="$USER_DIR" \
        LIB_DIR="$LIB_DIR" \
        CONFIG_FILE="$CONFIG_FILE" \
        bash "$root_script"
done

echo "[*] Running ${#user_scripts[@]} USER post-install stage(s)..."
for user_script in "${user_scripts[@]}"; do
    stage_name="$(basename "$user_script")"
    echo "[*] Running user stage $stage_name..."
    bash "$user_script"
done
