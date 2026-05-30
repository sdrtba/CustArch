#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

source "$LIB_DIR/profiles.sh"
load_install_profiles

main() {
  local -a packages

  reflector -c Russia -a 12 --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

  packages=(
      "${BASE_PACKAGES[@]}"
      "${HARDWARE_BOOT_PACKAGES[@]}"
  )

  case "$VM" in
      VBOX)
          packages+=(openssh virtualbox-guest-utils linux-headers)
          ;;
      VMWare)
          packages+=(openssh open-vm-tools)
          ;;
  esac

  pacstrap -K /mnt \
      "${packages[@]}"

  genfstab -U /mnt > /mnt/etc/fstab
}

main "$@"
