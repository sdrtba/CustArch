#!/usr/bin/env bash

MOUNT_OPTIONS="noatime,compress=zstd"

accept_plan() {
    local confirm

    cat <<EOF

Install plan
------------
Target disk:       $DISK
EFI partition:     $EFI_PART
Root partition:    $ROOT_PART
Format ESP:        $FORMAT_ESP
EOF

    read -rp "Type 'YES' to proceed with this plan: " confirm
    [[ "$confirm" == "YES" ]] || die "Canceled"
}

create_subvolumes() {
    mount "$ROOT_PART" /mnt

    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    btrfs subvolume create /mnt/@var_log
    btrfs subvolume create /mnt/@pkg

    umount /mnt
}

mount_filesystems() {
    mount -o "$MOUNT_OPTIONS,subvol=@" "$ROOT_PART" /mnt

    mkdir -p /mnt/{home,.snapshots,var/log,var/cache/pacman/pkg,boot}
    mount -o "$MOUNT_OPTIONS,subvol=@home" "$ROOT_PART" /mnt/home
    mount -o "$MOUNT_OPTIONS,subvol=@snapshots" "$ROOT_PART" /mnt/.snapshots
    mount -o "$MOUNT_OPTIONS,subvol=@var_log" "$ROOT_PART" /mnt/var/log
    mount -o "$MOUNT_OPTIONS,subvol=@pkg" "$ROOT_PART" /mnt/var/cache/pacman/pkg
    mount "$EFI_PART" /mnt/boot
}

mountpoint -q /mnt && die "/mnt is already mounted."

accept_plan

if [[ $FORMAT_ESP == "yes" ]]; then
    log "Formatting ESP partition"
    mkfs.fat -F 32 "$EFI_PART" || die "Failed to format EFI partition: $EFI_PART"
fi

log "Formatting ROOT partition: $ROOT_PART"
mkfs.btrfs -f "$ROOT_PART"
save_state_var ROOT_UUID "$(blkid -s UUID -o value "$ROOT_PART")"

mkdir -p /mnt
create_subvolumes
mount_filesystems
