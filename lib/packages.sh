#!/usr/bin/env bash

CORE_PACKAGES=(
    base
    linux
    linux-firmware
)

BUILD_PACKAGES=(
    base-devel
    rustup
)

BOOT_PACKAGES=(
    efibootmgr
    sbctl
)

ADMIN_PACKAGES=(
    sudo
    pacman-contrib
    reflector
    networkmanager
    openssh
    ufw
)

CLI_PACKAGES=(
    nano
    vim
    zsh
    fzf
    git
    curl
    wget
    rsync
    jq
    fastfetch
    htop
    btop
    p7zip
    zip
    unzip
    man-db
    man-pages
    texinfo
    tealdeer
)

STORAGE_PACKAGES=(
    zram-generator
    exfatprogs
)

BACKUP_PACKAGES=(
    timeshift
    # snapper
)

BTRFS_PACKAGES=(
    btrfs-progs
    # btrfs-assistant
    compsize
)

AMD_PACKAGES=(
    amd-ucode
    mesa
    vulkan-radeon
)

VM_PACKAGES=(
    foot
    mesa
    qemu-guest-agent
    virtualbox-guest-utils
    open-vm-tools
)

DESKTOP_BASE_PACKAGES=(
    xdg-utils
    xdg-user-dirs
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
    power-profiles-daemon
)

DESKTOP_PORTAL_PACKAGES=(
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
    kitty
    file-roller
    thunar
    thunar-archive-plugin
    tumbler
    ffmpegthumbnailer
    gvfs
    gvfs-smb
    gvfs-mtp
    udiskie
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
    hyprshot
    hyprpicker
    waybar
    rofi
    mako
    hyprpolkitagent
)

AUR_PACKAGES=(
    timeshift-autosnap
)

aur_packages() {
    printf '%s\n' "${AUR_PACKAGES[@]}"
}

target_packages() {
    printf '%s\n' "${CORE_PACKAGES[@]}"
    printf '%s\n' "${BUILD_PACKAGES[@]}"
    printf '%s\n' "${BOOT_PACKAGES[@]}"
    printf '%s\n' "${ADMIN_PACKAGES[@]}"
    printf '%s\n' "${CLI_PACKAGES[@]}"
    printf '%s\n' "${STORAGE_PACKAGES[@]}"
    printf '%s\n' "${BACKUP_PACKAGES[@]}"

    case "$FS_TYPE" in
        btrfs) printf '%s\n' "${BTRFS_PACKAGES[@]}" ;;
    esac

    case "$GPU" in
        amd) printf '%s\n' "${AMD_PACKAGES[@]}" ;;
        vm) printf '%s\n' "${VM_PACKAGES[@]}" ;;
    esac

    printf '%s\n' "${DESKTOP_BASE_PACKAGES[@]}"
    printf '%s\n' "${DESKTOP_AUDIO_PACKAGES[@]}"
    printf '%s\n' "${DESKTOP_HARDWARE_PACKAGES[@]}"
    printf '%s\n' "${DESKTOP_PORTAL_PACKAGES[@]}"
    printf '%s\n' "${DESKTOP_WAYLAND_PACKAGES[@]}"
    printf '%s\n' "${DESKTOP_APPS_PACKAGES[@]}"
    printf '%s\n' "${DESKTOP_STYLE_PACKAGES[@]}"
    printf '%s\n' "${HYPRLAND_PACKAGES[@]}"
}
