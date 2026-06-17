#!/usr/bin/env bash

PACSTRAP_PACKAGES=(
    base
    base-devel
    linux
    linux-firmware
    amd-ucode
    btrfs-progs
    dosfstools
    efibootmgr
    sbctl
    zram-generator
    sudo
    networkmanager
    nano
    vim
    curl
    wget
    git
    openssh
    reflector
    pacman-contrib
)

PACMAN_COMMON_PACKAGES=(
    mesa
    vulkan-radeon
    libva-mesa-driver

    wayland
    xorg-xwayland
    xdg-desktop-portal
    qt5-wayland
    qt6-wayland

    kitty

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
    timeshift

    hyprland
    hyprlock
    hypridle
    hyprpicker
    hyprpolkitagent
    xdg-desktop-portal-hyprland

    waybar
    swaync
    rofi-wayland
    swww
)

AUR_PACKAGES=(
    timeshift-autosnap
)
