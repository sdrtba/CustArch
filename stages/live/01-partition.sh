#!/usr/bin/env bash
set -Eeuo pipefail
source "$LIB_DIR/common.sh"
load_config
require_root

choose_disk() {
    local -a disks menu
    local disk info

    mapfile -t disks < <(lsblk -dpno NAME,TYPE | awk '$2 == "disk" { print $1 }')
    ((${#disks[@]} > 0)) || die "No disks found."

    log "Available disks:"
    lsblk -dp -o NAME,SIZE,MODEL,SERIAL,TRAN,TYPE

    for disk in "${disks[@]}"; do
        info="$(lsblk -dn -o SIZE,MODEL,SERIAL,TRAN -- "$disk")"
        menu+=("$disk  $info")
    done

    choose_from_list "Choose target disk" DISK "${menu[@]}"
    DISK="${DISK%% *}"
    log "Selected disk: $DISK"
}

choose_partition() {
    local prompt="$1"
    local result_var="$2"
    local -a partitions menu
    local part info selected

    mapfile -t partitions < <(lsblk -nrpo NAME,TYPE "$DISK" | awk '$2 == "part" { print $1 }')
    ((${#partitions[@]} > 0)) || die "No partitions found on $DISK."

    echo
    lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,TYPE,MOUNTPOINTS "$DISK"

    for part in "${partitions[@]}"; do
        info="$(lsblk -n -o SIZE,FSTYPE,LABEL,PARTLABEL -- "$part")"
        menu+=("$part  $info")
    done

    choose_from_list "$prompt" selected "${menu[@]}"
    selected="${selected%% *}"

    printf -v "$result_var" '%s' "$selected"
    log "Selected partition: $selected"
}

main() {
    choose_disk
    confirm_dialog "This will erase or modify partition data on: $DISK" "ERASE"

    cfdisk "$DISK"

    echo
    log "Resulting partition table:"
    lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS "$DISK"

    choose_partition "Choose existing EFI System Partition" EFI_PART
    choose_partition "Choose ROOT partition to format" ROOT_PART
    [[ "$EFI_PART" != "$ROOT_PART" ]] || die "EFI and ROOT partitions must be different."

    save_config_var DISK "$DISK"
    save_config_var EFI_PART "$EFI_PART"
    save_config_var ROOT_PART "$ROOT_PART"
}

main "$@"
