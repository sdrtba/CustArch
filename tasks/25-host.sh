#!/usr/bin/env bash

run_chroot() {
    printf '%s\n' "$HOSTNAME" > /etc/hostname
    install_template hosts /etc/hosts
    printf '127.0.0.1 %s.localdomain %s\n' "$HOSTNAME" "$HOSTNAME" >> /etc/hosts
}
