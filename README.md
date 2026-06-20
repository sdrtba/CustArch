# CustArch

CustArch is a Bash-based Arch Linux installer for a pre-partitioned UEFI system. The installer reads `manifest.conf` as a trusted shell configuration file, prints the target plan, asks for destructive confirmations, installs the base system, then continues configuration inside the chroot.

## Requirements

- Arch Linux live ISO booted in UEFI mode.
- Existing disk partitions for EFI and root.
- Network access during chroot and post-install stages.
- A reviewed `manifest.conf`; it is sourced as Bash and is intentionally trusted.

## Configuration

Edit `manifest.conf` before running the installer:

- `DISK`, `EFI_PART`, `ROOT_PART`: target block devices.
- `FS_TYPE`: `btrfs` or `ext4`.
- `FORMAT_ESP`: `yes` to format the EFI partition, `no` to keep it.
- `GPU`: `amd` or `vm`.
- `INSTALL_PARU`: build `paru` and install AUR packages during post-install when `yes`.
- `HOSTNAME`, `TIMEZONE`, `USERNAME`, `TARGET_DIR`: target system identity and installer path.

## Workflow

From the live ISO:

```bash
sudo ./install.sh
```

The live stage validates the manifest, shows the plan, formats and mounts the target partitions, installs packages with `pacstrap`, writes `/mnt/etc/fstab`, copies the installer into `TARGET_DIR`, and enters the chroot stage.

After the first reboot:

```bash
sudo /opt/custarch/install.sh --post
```

Use the actual `TARGET_DIR` value from `manifest.conf` if it differs from `/opt/custarch`.

## Logs

Each installer mode writes a session log to `/var/log/custarch/`:

- `live-<timestamp>.log`
- `chroot-<timestamp>.log`
- `post-<timestamp>.log`

The live log is also copied into the target system under `/var/log/custarch/` before entering the chroot stage. Override the location with `LOG_DIR` or the exact file with `LOG_FILE`.

## Task Layout

Tasks are loaded from `tasks/*.sh` in lexical order. Each task may expose `run_live`, `run_chroot`, or `run_post`; the runner calls only the function that matches the current installer mode.

- `00-validate.sh`: live ISO disk and partition validation.
- `05-disk.sh`: destructive formatting and target mounts.
- `10-base.sh`: package bootstrap, `fstab`, installer copy, chroot handoff.
- `15-pacman.sh`: pacman configuration.
- `20-locale.sh`: timezone, clock, locale, console keymap.
- `25-host.sh`: hostname and hosts file.
- `30-user.sh`: root and user account setup.
- `32-homefiles.sh`: managed user home seed from `home/`.
- `35-services.sh`: generated service config, systemd enables, firewall defaults.
- `40-boot.sh`: systemd-boot, kernel command line, mkinitcpio.
- `45-secureboot.sh`: Secure Boot signing and optional key enrollment.
- `50-chroot-finish.sh`: end-of-chroot instructions.
- `90-linger.sh`: post-reboot user linger setup.
- `91-aur.sh`: post-reboot `paru` bootstrap and AUR packages.
- `92-desktop-dirs.sh`: post-reboot desktop user directories.
- `95-snapshot.sh`: initial post-reboot Timeshift snapshot.
- `99-post-finish.sh`: post-reboot completion message.

## Package Layout

Package groups live in `lib/packages.sh`:

- `CORE_PACKAGES`: Arch base, kernel, firmware.
- `BUILD_PACKAGES`: build prerequisites used by post-install tasks.
- `BOOT_PACKAGES`: bootloader and Secure Boot tools.
- `ADMIN_PACKAGES`: sudo, pacman maintenance, mirrors, networking, SSH, firewall.
- `CLI_*_PACKAGES`: editor, shell, network/data, monitoring, archive, and manual tools.
- `STORAGE_PACKAGES`: storage/system helpers such as zram and exFAT tools.
- `BACKUP_PACKAGES`: backup tools.
- `BTRFS_PACKAGES`: filesystem-specific packages.
- `AMD_PACKAGES`, `VM_PACKAGES`: GPU/profile-specific packages.
- `DESKTOP_BASE_PACKAGES`: desktop integration basics such as XDG tools.
- `DESKTOP_AUDIO_PACKAGES`: PipeWire stack and audio controls.
- `DESKTOP_HARDWARE_PACKAGES`: Bluetooth, brightness, network tray tools.
- `DESKTOP_PORTAL_PACKAGES`: XDG utilities and portals.
- `DESKTOP_WAYLAND_PACKAGES`: clipboard, screenshots, media controls, Qt Wayland.
- `DESKTOP_APPS_PACKAGES`: user-facing apps such as browser, file manager, terminal.
- `DESKTOP_STYLE_PACKAGES`: fonts, icon themes, appearance tools.
- `HYPRLAND_PACKAGES`: compositor, lock/idle, launcher, bar, notifications, polkit agent.
- `AUR_PACKAGES`: packages installed during manual `--post` when `INSTALL_PARU=yes`.

## Home Files

Managed user files live under `home/` and are copied to `/home/$USERNAME` during the chroot stage.

Use this for files that should be part of a fresh installed profile:

- `.config/...`
- `.local/bin/...`
- `.local/share/applications/...`
- shell profile files such as `.profile`, `.zshrc`, or `.bashrc`

The copy is additive and does not use `--delete`, so repeated installer runs do not remove user-created files. The installer also excludes `.gitkeep`, `.cache/`, `.local/state/`, `.ssh/`, and `.gnupg/`.

## Safety Notes

- The root partition is always formatted.
- The EFI partition is formatted when `FORMAT_ESP=yes`.
- `/mnt` must not already be mounted before the live install starts.
- If disk setup fails after mounting `/mnt`, the installer attempts to unmount the target tree before exiting.
- `fstab` is regenerated for the installed system instead of being appended on repeated runs.
