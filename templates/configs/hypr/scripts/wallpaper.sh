#!/bin/bash
set -Eeuo pipefail

[[ -d "$HOME/.config/wallpapers" ]] || exit 0
WALL="$(find "$HOME/.config/wallpapers" -type f | shuf -n 1)"
[[ -n "$WALL" ]] || exit 0

swww img "$WALL" \
    --transition-type grow \
    --transition-duration 1
