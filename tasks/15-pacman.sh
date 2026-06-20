#!/usr/bin/env bash

run_chroot() {
    local conf="/etc/pacman.conf"

    [[ -f "$conf" ]] || die "pacman.conf not found: $conf"

    cp -an "$conf" "$conf.custarch.bak"

    sed -i \
        -e 's/^#Color$/Color/' \
        -e 's/^#\?ParallelDownloads = .*/ParallelDownloads = 10/' \
        "$conf"

    if ! grep -qx 'ILoveCandy' "$conf"; then
        sed -i '/^Color$/a ILoveCandy' "$conf"
    fi

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
