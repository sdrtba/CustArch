# Architecture

The installer has two separate concerns:

- stages decide when something runs
- profiles decide what gets installed and configured

Keep those concerns separate. A stage should describe an installation phase, not a personal package list.

## Entry Points

`boot.sh` is the live ISO entry point. It runs as root from the Arch live environment and executes `stages/live/*.sh`.

`stages/chroot/00-entry.sh` is the chroot entry point. It runs inside the target system during the base install.

`postinstall.sh` is the first-boot entry point. It runs as the configured user after reboot and uses `sudo` for root stages.

## Stages

Stages are ordered shell scripts. Their filenames define execution order.

`stages/live/` handles the machine while it is mounted at `/mnt`:

- partitioning
- formatting
- mounting
- `pacstrap`
- `genfstab`
- entering chroot

`stages/chroot/` handles the bootable base system:

- locale
- timezone
- hostname
- users
- sudo
- bootloader
- VM guest services

`stages/post/` handles the final workstation:

- Wi-Fi
- desktop packages
- AUR packages
- dotfiles
- runtime capabilities
- services

Post-install root stages run in two groups. Files with `services` in the name run after user stages, so service setup can depend on AUR packages installed by the user stage.

## Profiles

Profiles are sourced by stage scripts through `lib/profiles.sh`.

The selected profiles are configured in `settings.conf`:

```bash
BASE_PROFILE="base"
HARDWARE_PROFILE="amd"
DESKTOP_PROFILE="hyprland"
USER_PROFILE="default"
```

Current profile types:

- `profiles/base/*.sh` defines `BASE_PACKAGES`
- `profiles/hardware/*.sh` defines `HARDWARE_BOOT_PACKAGES` and `HARDWARE_PACKAGES`
- `profiles/desktop/*.sh` defines `DESKTOP_PACKAGES`
- `profiles/user/*.sh` defines `AUR_PACKAGES`

Package timing:

- `BASE_PACKAGES` and `HARDWARE_BOOT_PACKAGES` are installed by `pacstrap`
- `HARDWARE_PACKAGES` and `DESKTOP_PACKAGES` are installed after first boot with `pacman`
- `AUR_PACKAGES` are installed after first boot with `paru`

## Shared Library

`lib/common.sh` contains generic installer helpers:

- config loading
- root checks
- pacman wrapper
- systemd helpers
- dotfile copying

`lib/profiles.sh` contains profile loading only. It should stay small and not perform installation work.

## Assets

`assets/` stores files copied into the installed user account.

Current asset directories:

- `assets/configs/` is copied to `$HOME/.config`
- `assets/local/` is copied to `$HOME/.local`

Keep install logic out of `assets/`. Assets should be plain files that stages can copy.

## Direction

The next architectural step is to move service declarations and dotfile ownership into profiles too. For now, packages are the first layer extracted because they were the largest source of hardcoded personal state.

Target shape:

```text
settings.conf
boot.sh
postinstall.sh
lib/
  common.sh
  profiles.sh
stages/
  live/
  chroot/
  post/
    root/
    user/
profiles/
  base/
  hardware/
  desktop/
  user/
assets/
  configs/
  local/
```

This keeps the installer simple while making variants cheap: a new machine should mostly mean a new profile file, not edits across many stages.
