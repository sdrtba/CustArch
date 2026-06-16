#!/usr/bin/env bash

target_repo="/mnt/opt/custarch"
target_state="/mnt$STATE_FILE"

mountpoint -q /mnt || die "/mnt is not mounted."
mountpoint -q /mnt/boot || die "/mnt/boot is not mounted."

# shellcheck source=lib/packages.sh
source "$LIB_DIR/packages.sh"

log "Installing base system..."
pacstrap -K /mnt "${PACSTRAP_PACKAGES[@]}"

log "Generating fstab..."
genfstab -U /mnt > /mnt/etc/fstab

log "Copying installer to $target_repo..."
mkdir -p "$target_repo" "$(dirname -- "$target_state")"
cp -a "$ROOT_DIR"/. "$target_repo"/
cp "$STATE_FILE" "$target_state"

log "Entering installed system..."
arch-chroot /mnt /opt/custarch/install.sh chroot
