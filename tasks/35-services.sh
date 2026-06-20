#!/usr/bin/env bash

run_chroot() {
    install_template zram-generator.conf /etc/systemd/zram-generator.conf
    install_template reflector.conf /etc/xdg/reflector/reflector.conf
    install_template paccache.hook /etc/pacman.d/hooks/paccache.hook

    systemctl enable NetworkManager.service
    systemctl enable bluetooth.service
    systemctl enable ufw.service
    systemctl enable systemd-timesyncd.service
    systemctl enable systemd-zram-setup@zram0.service
    systemctl enable reflector.timer

    ufw default deny incoming
    ufw default allow outgoing

    if [[ -f /etc/ufw/ufw.conf ]]; then
        sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf
    fi
}
