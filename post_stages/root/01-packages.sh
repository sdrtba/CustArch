#!/usr/bin/env bash
set -euo pipefail
source "$LIB_DIR/common.sh"
load_config

packages=(
    wayland
    hyprland
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-user-dirs
    xdg-utils
    qt5-wayland
    qt6-wayland

    egl-wayland
    xorg-xwayland

    kitty
    waybar
    swaync
    dunst
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
    pipewire-jack
    pavucontrol

    wl-clipboard
    cliphist
    grim
    slurp
    brightnessctl
    playerctl
    power-profiles-daemon
    network-manager-applet
    polkit-gnome

    bluez
    bluez-utils
    blueman

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-dejavu
    ttf-jetbrains-mono-nerd

    zsh
)

packages+=(
    mesa vulkan-radeon libva-mesa-driver \
    git htop wget curl man-db man-pages texinfo \
	unzip ufw fastfetch rustup
)

if [[ ${#packages[@]} -gt 0 ]]; then
    pacman -S --needed --noconfirm "${packages[@]}"
fi
