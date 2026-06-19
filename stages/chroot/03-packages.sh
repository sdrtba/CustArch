#!/usr/bin/env bash

log "Installing common packages..."
pacman_install "${PACMAN_COMMON_PACKAGES[@]}"

#TODO: REMAKE LOGIC WITH PACKAGES. DEPENDS ON DIFFERENT CONDITIONS
