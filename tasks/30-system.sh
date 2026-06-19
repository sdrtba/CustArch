#!/usr/bin/env bash

configure_pacman_conf() {
    local conf="/etc/pacman.conf"

    [[ -f "$conf" ]] || die "pacman.conf not found: $conf"

    cp -an "$conf" "$conf.custarch.bak"

    sed -i \
        -e 's/^#Color$/Color/' \
        -e 's/^#\?ParallelDownloads = .*/ParallelDownloads = 10/' \
        "$conf"
    sed -i '/^Color$/a ILoveCandy' "$conf"

    if grep -q '^\[multilib\]' "$conf"; then
        return 0
    fi

    if grep -q '^#\[multilib\]' "$conf"; then
        sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//;}' "$conf"
        return 0
    fi

    cat >> "$conf" <<'EOF'
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
}

run_chroot() {
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    hwclock --systohc

    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    printf 'LANG=en_US.UTF-8\n' > /etc/locale.conf
    printf 'KEYMAP=us\n' > /etc/vconsole.conf

    printf '%s\n' "$HOSTNAME" > /etc/hostname
    cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

    configure_pacman_conf

    install_template zram-generator.conf /etc/systemd/zram-generator.conf
    install_template paccache.hook /etc/pacman.d/hooks/paccache.hook
    install_template reflector.conf /etc/xdg/reflector/reflector.conf

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
