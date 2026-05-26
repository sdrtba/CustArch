#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STAGES_DIR="$ROOT_DIR/stages"
POST_DIR="$STAGES_DIR/post"
ROOT_DIR="$POST_DIR/root"
USER_DIR="$POST_DIR/user"
LIB_DIR="$ROOT_DIR/lib"
CONFIG_FILE="$ROOT_DIR/settings.conf"
ASSETS_DIR="$ROOT_DIR/assets"
CONFIG_DIR="$ASSETS_DIR/configs"
LOCAL_DIR="$ASSETS_DIR/local"
export ROOT_DIR STAGES_DIR POST_DIR ROOT_DIR USER_DIR LIB_DIR CONFIG_FILE ASSETS_DIR CONFIG_DIR LOCAL_DIR

source "$LIB_DIR/common.sh"
load_config

create_pre_postinstall_snapshot() {
    local snapshot_name

    if [[ "$FS_TYPE" != "btrfs" ]]; then
        echo "[*] Root filesystem is ${FS_TYPE:-unknown}, skipping pre-postinstall snapshot."
        return 0
    fi

    snapshot_name="pre-postinstall-$(date +%Y%m%d-%H%M%S)"

    sudo timeshift --create --comments "$snapshot_name"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    echo "[*] Snapshot created"
}

if [[ "$(id -un)" != "$USERNAME" ]]; then
    echo "[!] Run this script as $USERNAME"
    exit 1
fi

mapfile -t root_scripts < <(find "$ROOT_DIR" -maxdepth 1 -type f -name '*.sh' | sort)
mapfile -t user_scripts < <(find "$USER_DIR" -maxdepth 1 -type f -name '*.sh' | sort)
root_setup_scripts=()
root_service_scripts=()

for root_script in "${root_scripts[@]}"; do
    case "$(basename "$root_script")" in
        *services*.sh)
            root_service_scripts+=("$root_script")
            ;;
        *)
            root_setup_scripts+=("$root_script")
            ;;
    esac
done

create_pre_postinstall_snapshot

run_root_stage() {
    local root_script="$1"
    local stage_name

    stage_name="$(basename "$root_script")"
    echo "[*] Running root stage $stage_name..."
    sudo env \
        ROOT_DIR="$ROOT_DIR" \
        STAGES_DIR="$STAGES_DIR" \
        POST_DIR="$POST_DIR" \
        ROOT_DIR="$ROOT_DIR" \
        USER_DIR="$USER_DIR" \
        LIB_DIR="$LIB_DIR" \
        CONFIG_FILE="$CONFIG_FILE" \
        ASSETS_DIR="$ASSETS_DIR" \
        CONFIG_DIR="$CONFIG_DIR" \
        LOCAL_DIR="$LOCAL_DIR" \
        bash "$root_script"
}

echo "[*] Running ${#root_setup_scripts[@]} ROOT setup stage(s)..."
for root_script in "${root_setup_scripts[@]}"; do
    run_root_stage "$root_script"
done

echo "[*] Running ${#user_scripts[@]} USER post-install stage(s)..."
for user_script in "${user_scripts[@]}"; do
    stage_name="$(basename "$user_script")"
    echo "[*] Running user stage $stage_name..."
    bash "$user_script"
done

echo "[*] Running ${#root_service_scripts[@]} ROOT service stage(s)..."
for root_script in "${root_service_scripts[@]}"; do
    run_root_stage "$root_script"
done
