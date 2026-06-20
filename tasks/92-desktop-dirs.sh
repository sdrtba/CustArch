#!/usr/bin/env bash

run_post() {
    runuser -u "$USERNAME" -- xdg-user-dirs-update || true
}
