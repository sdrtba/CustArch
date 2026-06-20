#!/usr/bin/env bash

BASE_PACKAGES=(
    base
    base-devel
    linux
    linux-firmware
)

ADMIN_PACKAGES=(
    sudo
    networkmanager
    openssh
    ufw
    reflector
    pacman-contrib
    efibootmgr
    sbctl
)

CLI_PACKAGES=(
    git
    nano
    vim
    curl
    wget
    rsync
    jq
    zsh
    fzf
    fastfetch
    htop
    man-db
    man-pages
    texinfo
    unzip
)

SYSTEM_PACKAGES=(
    zram-generator
)

BACKUP_PACKAGES=(
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

DESKTOP_AUDIO_PACKAGES=(
    pipewire
    pipewire-alsa
    pipewire-audio
    pipewire-jack
    pipewire-pulse
    wireplumber
    pavucontrol
)

DESKTOP_HARDWARE_PACKAGES=(
    bluez
    bluez-utils
    blueman
    brightnessctl
    network-manager-applet
)

DESKTOP_PORTAL_PACKAGES=(
    xdg-utils
    xdg-user-dirs
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
)

DESKTOP_WAYLAND_PACKAGES=(
    wl-clipboard
    cliphist
    grim
    slurp
    swappy
    playerctl
    pamixer
    qt5-wayland
    qt6-wayland
)

DESKTOP_APPS_PACKAGES=(
    firefox
    thunar
    thunar-archive-plugin
    tumbler
    gvfs
    file-roller
    kitty
)

DESKTOP_STYLE_PACKAGES=(
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-dejavu
    ttf-jetbrains-mono-nerd
    adwaita-icon-theme
    papirus-icon-theme
    nwg-look
    qt5ct
    qt6ct
)

HYPRLAND_PACKAGES=(
    hyprland
    hyprlock
    hypridle
    hyprpicker
    waybar
    rofi-wayland
    mako
    polkit-gnome
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
    printf '%s\n' "${ADMIN_PACKAGES[@]}"
    printf '%s\n' "${CLI_PACKAGES[@]}"
    printf '%s\n' "${SYSTEM_PACKAGES[@]}"
    printf '%s\n' "${BACKUP_PACKAGES[@]}"

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
        printf '%s\n' "${DESKTOP_AUDIO_PACKAGES[@]}"
        printf '%s\n' "${DESKTOP_HARDWARE_PACKAGES[@]}"
        printf '%s\n' "${DESKTOP_PORTAL_PACKAGES[@]}"
        printf '%s\n' "${DESKTOP_WAYLAND_PACKAGES[@]}"
        printf '%s\n' "${DESKTOP_APPS_PACKAGES[@]}"
        printf '%s\n' "${DESKTOP_STYLE_PACKAGES[@]}"
        printf '%s\n' "${HYPRLAND_PACKAGES[@]}"
    fi
}
