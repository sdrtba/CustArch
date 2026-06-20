#!/usr/bin/env bash

run_live() {
    local mounted_target="no"

    # shellcheck disable=SC2329
    disk_cleanup_mounts_on_error() {
        if [[ "$mounted_target" == "yes" ]]; then
            warn "Cleaning up mounted target after disk setup failure."
            if findmnt -R /mnt >/dev/null 2>&1; then
                umount -R /mnt || warn "Could not unmount /mnt cleanly."
            fi
        fi
    }
    trap disk_cleanup_mounts_on_error ERR

    if [[ "$FORMAT_ESP" == "yes" ]]; then
        mkfs.fat -F32 "$EFI_PART"
    fi

    case "$FS_TYPE" in
        btrfs)
            mkfs.btrfs -f "$ROOT_PART"
            mount "$ROOT_PART" /mnt
            mounted_target="yes"
            btrfs subvolume create /mnt/@
            btrfs subvolume create /mnt/@home
            btrfs subvolume create /mnt/@snapshots
            btrfs subvolume create /mnt/@var_log
            btrfs subvolume create /mnt/@pkg
            umount /mnt
            mounted_target="no"

            mount -o "$MOUNT_OPTIONS,subvol=@" "$ROOT_PART" /mnt
            mounted_target="yes"
            mkdir -p /mnt/{boot,home,.snapshots,var/log,var/cache/pacman/pkg}
            mount -o "$MOUNT_OPTIONS,subvol=@home" "$ROOT_PART" /mnt/home
            mount -o "$MOUNT_OPTIONS,subvol=@snapshots" "$ROOT_PART" /mnt/.snapshots
            mount -o "$MOUNT_OPTIONS,subvol=@var_log" "$ROOT_PART" /mnt/var/log
            mount -o "$MOUNT_OPTIONS,subvol=@pkg" "$ROOT_PART" /mnt/var/cache/pacman/pkg
            ;;
        ext4)
            mkfs.ext4 -F "$ROOT_PART"
            mount "$ROOT_PART" /mnt
            mounted_target="yes"
            mkdir -p /mnt/boot
            ;;
    esac

    mount "$EFI_PART" /mnt/boot
    trap - ERR
}
