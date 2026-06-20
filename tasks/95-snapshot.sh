#!/usr/bin/env bash

run_post() {
    if command -v timeshift >/dev/null 2>&1; then
        timeshift --create --comments "CustArch initial snapshot" || true
    fi
}
