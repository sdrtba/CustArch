#!/usr/bin/env bash

# shellcheck disable=SC2034
PACSTRAP_PACKAGES=(
    base
    base-devel
    linux
    linux-firmware
    efibootmgr
    grub
    os-prober
    zram-generator
    sudo
    reflector
    networkmanager
    nano
    vim
    curl
    wget
    git
    openssh
)

if [[ "$FS_TYPE" = "btrfs" ]]; then
    PACSTRAP_PACKAGES+=(grub-btrfs btrfs-progs timeshift)
fi

case "$VM" in
    VBOX)
        PACSTRAP_PACKAGES+=(virtualbox-guest-utils linux-headers)
        ;;
    VMWare)
        PACSTRAP_PACKAGES+=(open-vm-tools)
        ;;
esac

# shellcheck disable=SC2034
PACMAN_PACKAGES=(
    mesa
    vulkan-radeon
    libva-mesa-driver

    wayland
    hyprland
    hyprlock
    hypridle
    hyprpicker
    hyprpolkitagent
    xorg-xwayland
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    qt5-wayland
    qt6-wayland

    kitty
    waybar
    swaync
    rofi-wayland
    swww
    wlogout

    pipewire
    wireplumber
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    pipewire-audio
    pavucontrol
    playerctl

    dolphin
    kio-extras
    ark
    udisks2
    udiskie
    xdg-utils
    xdg-user-dirs

    bluez
    bluez-utils
    blueman
    network-manager-applet
    nftables

    power-profiles-daemon
    brightnessctl
    acpi

    wl-clipboard
    cliphist

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-dejavu
    ttf-jetbrains-mono-nerd

    grim
    slurp

    jq
    zsh
    fzf
    fastfetch
    firefox
    htop
    man-db
    man-pages
    texinfo
    unzip
    ufw
    rustup
)

# shellcheck disable=SC2034
AUR_PACKAGES=(
    timeshift-autosnap
    clash-verge-rev-bin
)
