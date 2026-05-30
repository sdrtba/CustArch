#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/paths.sh"
source "$LIB_DIR/common.sh"
load_config

main() {
    copy_tree_contents "$CONFIG_DIR" "$HOME/.config"
    copy_tree_contents "$LOCAL_DIR" "$HOME/.local"
}

main "$@"
