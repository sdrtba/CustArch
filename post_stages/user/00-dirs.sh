#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

mkdir -p "$HOME/.config"
cp -r "$CONFIG_DIR/"* "$HOME/.config/"

mkdir -p "$HOME/.local/"
cp -r "$LOCAL_DIR/"* "$HOME/.local/"
