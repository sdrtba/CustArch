#!/usr/bin/env bash

run_post() {
    log "Enabling user linger for $USERNAME..."
    loginctl enable-linger "$USERNAME"
}
