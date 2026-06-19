#!/usr/bin/env bash

log "Checking firstboot environment..."

[[ -d /run/systemd/system ]] || die "This phase must run on a booted system with systemd."

id "$USERNAME" >/dev/null 2>&1 || die "User does not exist: $USERNAME"

log "Firstboot environment is ready."
