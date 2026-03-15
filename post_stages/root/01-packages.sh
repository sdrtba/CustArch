#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

packages=(
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
)

packages+=(
    mesa vulkan-radeon libva-mesa-driver \
    git htop wget curl man-db man-pages texinfo \
	unzip ufw fastfetch rustup
)

if [[ ${#packages[@]} -gt 0 ]]; then
    pacman -S --needed --noconfirm "${packages[@]}"
fi
