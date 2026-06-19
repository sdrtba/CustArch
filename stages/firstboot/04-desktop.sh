#!/usr/bin/env bash

log "Enabling user linger for $USERNAME..."
loginctl enable-linger "$USERNAME"
