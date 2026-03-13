#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

packages=(
    wayland
    hyprland
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    qt5-wayland
    qt6-wayland

    kitty
    waybar
    swaync
    rofi
    hyprlock
    hypridle
    hyprpaper
    swww

    thunar
    thunar-archive-plugin
    file-roller

    pipewire
    wireplumber
    pipewire-pulse
    pavucontrol

    wl-clipboard
    grim
    slurp
    brightnessctl
    playerctl
    network-manager-applet
    blueman
    polkit-gnome

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-dejavu
    ttf-jetbrains-mono-nerd

    lxqt-policykit

    zsh
)

packages+=(
    mesa vulkan-radeon libva-mesa-driver mesa-vdpau \
    git htop wget curl man-db man-pages texinfo \
	unzip ufw timeshift fastfetch
)

if [[ ${#packages[@]} -gt 0 ]]; then
    pacman -S --needed --noconfirm "${packages[@]}"
fi
