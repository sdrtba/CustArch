#!/usr/bin/env bash
set -Eeuo pipefail

log() {
    printf '[*] %s\n' "$*" >&2
}

warn() {
    printf '[!] %s\n' "$*" >&2
}

die() {
    printf '[!] %s\n' "$*" >&2
    exit 1
}

require_root() {
    (( EUID == 0 )) || die "This stage must be run as root."
}

require_file() {
    local file="$1"
    [[ -f "$file" ]] || die "Required file not found: $file"
    [[ -r "$file" ]] || die "Required file is not readable: $file"
}

load_config() {
    require_file "$CONFIG_FILE"
    source "$CONFIG_FILE"
    : "${FS_TYPE:=ext4}"
    : "${VM:=}"
    export FS_TYPE VM
}

save_config_var() {
    local key="$1"
    local value="$2"
    local escaped_value
    escaped_value="${value//\\/\\\\}"
    escaped_value="${escaped_value//\"/\\\"}"

    if grep -q "^${key}=" "$CONFIG_FILE"; then
        sed -i "s|^${key}=.*|${key}=\"${escaped_value}\"|" "$CONFIG_FILE"
    else
        echo "${key}=\"${escaped_value}\"" >> "$CONFIG_FILE"
    fi
}

pacman_install() {
    local packages=("$@")
    ((${#packages[@]} > 0)) || return 0
    pacman -S --needed --noconfirm "${packages[@]}"
}

enable_service() {
    local service="$1"
    systemctl enable "$service"
}

start_service() {
    local service="$1"
    if [[ -d /run/systemd/system ]]; then
        systemctl start "$service"
    else
        warn "systemd is not running, skipping service start: $service"
    fi
}

copy_tree_contents() {
    local source_dir="$1"
    local target_dir="$2"

    [[ -d "$source_dir" ]] || {
        warn "Source directory does not exist, skipping copy: $source_dir"
        return 0
    }

    mkdir -p "$target_dir"
    cp -a "$source_dir"/. "$target_dir"/
}

choose_from_list() {
    local prompt="$1"
    local result_var="$2"
    shift 2

    local -a items=("$@")
    local choice i

    ((${#items[@]} > 0)) || die "Nothing to choose from: $prompt"

    echo
    log "$prompt"
    for i in "${!items[@]}"; do
        printf '%d) %s\n' "$((i + 1))" "${items[$i]}"
    done

    echo
    read -r -p "Choose number: " choice

    [[ "$choice" =~ ^[0-9]+$ ]] || die "Invalid choice."
    ((choice >= 1 && choice <= ${#items[@]})) || die "Choice out of range."

    printf -v "$result_var" '%s' "${items[$((choice - 1))]}"
}

confirm_dialog() {
    local prompt="$1"
    local confirm="$2"
    local check
    echo
    log "$prompt"
    read -r -p "Type $confirm to continue: " check
    [[ "$check" == "$confirm" ]] || die "Confirmation cancelled."
}
