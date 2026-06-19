#!/usr/bin/env bash

install_template() {
    local source_name="$1"
    local target_path="$2"
    local source_path="$SCRIPT_DIR/templates/$source_name"

    [[ -r "$source_path" ]] || die "Template is not readable: $source_path"
    mkdir -p "$(dirname -- "$target_path")"
    install -m 0644 "$source_path" "$target_path"
}

install_rendered_template() {
    local source_name="$1"
    local target_path="$2"
    local source_path="$SCRIPT_DIR/templates/$source_name"

    [[ -r "$source_path" ]] || die "Template is not readable: $source_path"
    mkdir -p "$(dirname -- "$target_path")"
    envsubst < "$source_path" > "$target_path"
    chmod 0644 "$target_path"
}
