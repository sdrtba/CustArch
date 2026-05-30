#!/usr/bin/env bash
set -Eeuo pipefail

prepare() {
  ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
  source "$ROOT_DIR/lib/paths.sh"
  source "$LIB_DIR/common.sh"
  load_config
  require_root

  exec > >(tee -a "$LOG_FILE") 2>&1
}

main() {
  prepare

  mapfile -t chroot_scripts < <(find "$CHROOT_DIR" -maxdepth 1 -type f -name '*.sh' ! -name '00-entry.sh' | sort)
  log "Running ${#chroot_scripts[@]} chroot stage(s)..."
  for chroot_script in "${chroot_scripts[@]}"; do
      stage_name="$(basename "$chroot_script")"
      log "Running $stage_name..."
      bash "$chroot_script"
  done

  log "Chroot stages finished."
}

main "$@"
