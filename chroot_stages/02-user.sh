#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

echo "Set root password"
passwd

echo "Create a new user"
useradd -m -G wheel -s /bin/bash "$USERNAME"
passwd "$USERNAME"

echo "$USERNAME ALL=(ALL) ALL" > "/etc/sudoers.d/$USERNAME"
chmod 0440 "/etc/sudoers.d/$USERNAME"

TARGET_REPO="/home/"$USERNAME"/CustArch"

rm -rf "$TARGET_REPO"
mkdir -p "$TARGET_REPO"
cp -a "$SCRIPT_DIR"/. "$TARGET_REPO"/
chown -R "$USERNAME":"$USERNAME" "$TARGET_REPO"
