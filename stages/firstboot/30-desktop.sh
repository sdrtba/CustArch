#!/usr/bin/env bash

[[ -n "$USERNAME" ]] || die "USERNAME is not set."
id "$USERNAME" >/dev/null 2>&1 || die "User does not exist: $USERNAME"

if [[ -x /usr/bin/zsh ]]; then
    current_shell="$(getent passwd "$USERNAME" | cut -d: -f7)"

    if [[ "$current_shell" != "/usr/bin/zsh" ]]; then
        log "Setting zsh as default shell for $USERNAME..."
        chsh -s /usr/bin/zsh "$USERNAME"
    fi
else
    warn "zsh is not installed, leaving default shell unchanged."
fi

log "Enabling user linger for $USERNAME..."
loginctl enable-linger "$USERNAME"
