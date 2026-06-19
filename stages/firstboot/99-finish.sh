#!/usr/bin/env bash

log "Disabling firstboot service..."
systemctl disable custarch-firstboot.service

log "Firstboot setup is complete."
