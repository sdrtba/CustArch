#!/usr/bin/env bash

BASE_PACKAGES=(
    base
    base-devel
    linux
    linux-firmware
    sudo
    networkmanager
    git
    nano
    vim
    curl
    wget
    openssh
    reflector
    pacman-contrib
    zram-generator
    efibootmgr
    sbctl
    jq
    zsh
    fzf
    fastfetch
    htop
    man-db
    man-pages
    texinfo
    unzip
    ufw
    timeshift
    rustup
)

BTRFS_PACKAGES=(
    btrfs-progs
)

EXT4_PACKAGES=(
)

AMD_PACKAGES=(
    amd-ucode
    mesa
    vulkan-radeon
    libva-mesa-driver
)

NVIDIA_PACKAGES=(
    nvidia
    nvidia-utils
    nvidia-settings
)

VM_PACKAGES=(
    mesa
    qemu-guest-agent
)

DESKTOP_PACKAGES=(
    pipewire
    pipewire-alsa
    pipewire-audio
    pipewire-jack
    pipewire-pulse
    wireplumber
    pavucontrol
    bluez
    bluez-utils
    brightnessctl
    xdg-utils
    xdg-user-dirs
    wl-clipboard
    grim
    slurp
    kitty
    hyprland
    hyprlock
    hypridle
    hyprpicker
    xdg-desktop-portal-hyprland
    waybar
    rofi-wayland
)

AUR_PACKAGES=(
    paru
    timeshift-autosnap
)

aur_packages() {
    printf '%s\n' "${AUR_PACKAGES[@]}"
}

target_packages() {
    printf '%s\n' "${BASE_PACKAGES[@]}"

    case "$FS_TYPE" in
        btrfs) printf '%s\n' "${BTRFS_PACKAGES[@]}" ;;
        ext4) printf '%s\n' "${EXT4_PACKAGES[@]}" ;;
    esac

    case "$GPU" in
        amd) printf '%s\n' "${AMD_PACKAGES[@]}" ;;
        nvidia) printf '%s\n' "${NVIDIA_PACKAGES[@]}" ;;
        vm) printf '%s\n' "${VM_PACKAGES[@]}" ;;
    esac

    if [[ "$INSTALL_HYPRLAND" == "yes" ]]; then
        printf '%s\n' "${DESKTOP_PACKAGES[@]}"
    fi
}
