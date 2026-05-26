#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

echo "Set root password"
passwd

if id "$USERNAME" >/dev/null 2>&1; then
    echo "User $USERNAME already exists, skipping creation"
else
    echo "Create a new user"
    useradd -m -G wheel -s /bin/bash "$USERNAME"
    passwd "$USERNAME"
fi

echo "$USERNAME ALL=(ALL) ALL" > "/etc/sudoers.d/$USERNAME"
chmod 0440 "/etc/sudoers.d/$USERNAME"

TARGET_REPO="/home/$USERNAME/CustArch"

rm -rf "$TARGET_REPO"
mkdir -p "$TARGET_REPO"
cp -a "$ROOT_DIR"/. "$TARGET_REPO"/
chown -R "$USERNAME":"$USERNAME" "$TARGET_REPO"
