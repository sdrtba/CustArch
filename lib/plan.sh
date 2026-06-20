#!/usr/bin/env bash

print_plan() {
    cat <<EOF

Desired CustArch 2.0 system
---------------------------
Disk:              $DISK
EFI partition:     $EFI_PART
Root partition:    $ROOT_PART
Root filesystem:   $FS_TYPE
Format ESP:        $FORMAT_ESP
Mount options:     $MOUNT_OPTIONS

Hostname:          $HOSTNAME
Timezone:          $TIMEZONE
Username:          $USERNAME

GPU profile:       $GPU
Install Hyprland:  $INSTALL_HYPRLAND
Install paru:      $INSTALL_PARU
Install homefiles: $INSTALL_HOMEFILES

Generated files:
  /etc/systemd/zram-generator.conf
  /etc/pacman.d/hooks/paccache.hook
  /etc/xdg/reflector/reflector.conf
  /etc/mkinitcpio.d/linux.preset
  /boot/loader/loader.conf
  /etc/pacman.d/hooks/99-secureboot-sign.hook
EOF
}

confirm_dangerous_plan() {
    confirm_exact "Root partition will be formatted: $ROOT_PART" "FORMAT $ROOT_PART"

    if [[ "$FORMAT_ESP" == "yes" ]]; then
        confirm_exact "ESP formatting is enabled: $EFI_PART" "FORMAT $EFI_PART"
    fi
}
