#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

TARGET_REPO="/mnt/root/CustArch"

rm -rf "$TARGET_REPO"
mkdir -p /mnt/root
cp -r "$SCRIPT_DIR" "$TARGET_REPO"
