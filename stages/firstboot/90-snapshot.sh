#!/usr/bin/env bash

snapshot_comment="CustArch firstboot complete"

if ! command -v timeshift >/dev/null 2>&1; then
    warn "timeshift is not installed, skipping initial snapshot."
elif timeshift --create --comments "$snapshot_comment" --tags O; then
    log "Initial Timeshift snapshot created."
else
    warn "Initial Timeshift snapshot failed."
fi
