#!/usr/bin/env bash
set -Eeuo pipefail

pkill waybar >/dev/null 2>&1 || true
waybar &
