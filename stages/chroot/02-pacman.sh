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

configure_paccache_hook() {
    mkdir -p /etc/pacman.d/hooks
    cat > /etc/pacman.d/hooks/paccache.hook <<'EOF'
[Trigger]
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Removing old cached packages...
When = PostTransaction
Exec = /usr/bin/paccache -rk2
EOF
}

refresh_mirrorlist() {
    log "Refreshing pacman mirrorlist with reflector..."
    reflector \
        --protocol https \
        --latest 20 \
        --sort rate \
        --save "/etc/pacman.d/mirrorlist"
}

configure_reflector_timer() {
    mkdir -p /etc/xdg/reflector
    cat > /etc/xdg/reflector/reflector.conf <<'EOF'
--save /etc/pacman.d/mirrorlist
--protocol https
--latest 20
--sort rate
EOF

    systemctl enable reflector.timer
}

log "Configuring pacman..."
configure_pacman_conf
configure_paccache_hook
configure_reflector_timer
refresh_mirrorlist

log "Refreshing package databases..."
pacman -Syy --noconfirm
