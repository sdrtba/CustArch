#!/usr/bin/env bash

STATE_FILE="/var/lib/custarch/state.env"

init_state() {
    mkdir -p "$(dirname -- "$STATE_FILE")"
    cp "$INIT_FILE" "$STATE_FILE"
}

load_state() {
    [[ -r "$STATE_FILE" ]] || die "State file is not readable: $STATE_FILE"
    source "$STATE_FILE"
}

save_state_var() {
    local key="$1"
    local value="$2"
    local state_dir tmp

    [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die "Invalid state key: $key"

    state_dir="$(dirname -- "$STATE_FILE")"
    mkdir -p "$state_dir"

    tmp="$(mktemp "$state_dir/state.env.XXXXXX")"

    if [[ -f "$STATE_FILE" ]]; then
        grep -v "^${key}=" "$STATE_FILE" > "$tmp" || true
    fi

    printf '%s=%q\n' "$key" "$value" >> "$tmp"
    mv "$tmp" "$STATE_FILE"
}
