#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

copy_tree_contents "$CONFIG_DIR" "$HOME/.config"

copy_tree_contents "$LOCAL_DIR" "$HOME/.local"
