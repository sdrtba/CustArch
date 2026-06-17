#!/usr/bin/env bash

home_dir="/home/$USERNAME"

[[ -n "$USERNAME" ]] || die "USERNAME is not set."
[[ -d "$home_dir" ]] || die "Home directory not found: $home_dir"

log "Installing user configuration templates..."
copy_tree_contents "$ROOT_DIR/templates/configs" "$home_dir/.config"
copy_tree_contents "$ROOT_DIR/templates/local" "$home_dir/.local"

chown -R "$USERNAME:$USERNAME" "$home_dir/.config" "$home_dir/.local"

log "Creating XDG user directories..."
runuser -u "$USERNAME" -- xdg-user-dirs-update
