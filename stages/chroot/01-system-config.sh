#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

main() {
    PACMAN_CONF="/etc/pacman.conf"

    sed -i 's/^#Color$/Color/' "$PACMAN_CONF"
    sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' "$PACMAN_CONF"

    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    hwclock --systohc

    sed -Ei 's/^#(en_US\.UTF-8[[:space:]]+UTF-8)[[:space:]]*$/\1/' /etc/locale.gen
    sed -Ei 's/^#(ru_RU\.UTF-8[[:space:]]+UTF-8)[[:space:]]*$/\1/' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

    echo "$HOSTNAME" > /etc/hostname

    systemctl enable NetworkManager
    systemctl enable reflector.timer

    if [ "$VM" ]; then
        systemctl enable sshd
    fi
    case "$VM" in
        VBOX)
        systemctl enable vboxservice
        ;;
        VMWare)
        systemctl enable vmtoolsd
        ;;
    esac
}

main "$@"

#en_US.UTF-8 UTF-8
#ru_RU.UTF-8 UTF-8
