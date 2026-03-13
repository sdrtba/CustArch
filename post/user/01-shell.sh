#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

# Configure shell, prompt, aliases, and CLI tools here.

cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
rustup default stable
makepkg -si
