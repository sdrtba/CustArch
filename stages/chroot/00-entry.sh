#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
STAGES_DIR="$ROOT_DIR/stages"
CHROOT_DIR="$STAGES_DIR/chroot"
LIB_DIR="$ROOT_DIR/lib"
CONFIG_FILE="$ROOT_DIR/settings.conf"
export ROOT_DIR STAGES_DIR CHROOT_DIR LIB_DIR CONFIG_FILE

source "$LIB_DIR/common.sh"
load_config

mapfile -t chroot_scripts < <(find "$CHROOT_DIR" -maxdepth 1 -type f -name '*.sh' ! -name '00-entry.sh' | sort)

echo "[*] Running ${#chroot_scripts[@]} chroot stage(s)..."
for chroot_script in "${chroot_scripts[@]}"; do
    stage_name="$(basename "$chroot_script")"
    echo "[*] Running $stage_name..."
    bash "$chroot_script"
done

echo "[*] Chroot stages finished."
