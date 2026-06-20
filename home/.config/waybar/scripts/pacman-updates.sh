#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v checkupdates >/dev/null 2>&1; then
    printf '{"text":"","tooltip":"pacman-contrib is not installed","class":"missing"}\n'
    exit 0
fi

updates="$(checkupdates 2>/dev/null || true)"

if [[ -z "$updates" ]]; then
    printf '{"text":"","tooltip":"System is up to date","class":"clean"}\n'
    exit 0
fi

count="$(printf '%s\n' "$updates" | wc -l)"
printf '{"text":"󰏖 %s","tooltip":"%s package updates available","class":"updates"}\n' "$count" "$count"
