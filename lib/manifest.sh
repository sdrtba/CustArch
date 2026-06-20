#!/usr/bin/env bash

MANIFEST_FILE="${MANIFEST_FILE:-$SCRIPT_DIR/manifest.conf}"

load_manifest() {
    [[ -r "$MANIFEST_FILE" ]] || die "Manifest is not readable: $MANIFEST_FILE"
    source "$MANIFEST_FILE"
}

validate_yes_no() {
    local name="$1"
    local value="$2"

    [[ "$value" == "yes" || "$value" == "no" ]] ||
        die "$name must be yes or no, got: $value"
}

validate_manifest() {
    : "${DISK:?DISK is required}"
    : "${EFI_PART:?EFI_PART is required}"
    : "${ROOT_PART:?ROOT_PART is required}"
    : "${FS_TYPE:?FS_TYPE is required}"
    : "${FORMAT_ESP:?FORMAT_ESP is required}"
    : "${GPU:?GPU is required}"
    : "${INSTALL_PARU:?INSTALL_PARU is required}"
    : "${HOSTNAME:?HOSTNAME is required}"
    : "${TIMEZONE:?TIMEZONE is required}"
    : "${USERNAME:?USERNAME is required}"
    : "${TARGET_DIR:?TARGET_DIR is required}"

    [[ "$FS_TYPE" == "btrfs" || "$FS_TYPE" == "ext4" ]] ||
        die "FS_TYPE must be btrfs or ext4, got: $FS_TYPE"
    [[ "$GPU" == "amd" || "$GPU" == "vm" ]] ||
        die "GPU must be amd or vm, got: $GPU"

    validate_yes_no FORMAT_ESP "$FORMAT_ESP"
    validate_yes_no INSTALL_PARU "$INSTALL_PARU"

    [[ "$EFI_PART" != "$ROOT_PART" ]] || die "EFI_PART and ROOT_PART must be different."
    [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || die "Invalid USERNAME: $USERNAME"
    [[ "$HOSTNAME" =~ ^[A-Za-z0-9][A-Za-z0-9-]{0,62}$ ]] || die "Invalid HOSTNAME: $HOSTNAME"
    [[ "$TARGET_DIR" == /* ]] || die "TARGET_DIR must be an absolute path: $TARGET_DIR"
}
