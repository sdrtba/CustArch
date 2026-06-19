#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/manifest.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/templates.sh"
source "$SCRIPT_DIR/lib/plan.sh"
source "$SCRIPT_DIR/lib/runner.sh"

usage() {
    cat <<EOF
Usage:
  ./install.sh              run live installer
  ./install.sh --chroot     continue inside chroot
  ./install.sh --post       run post-install tasks after reboot
  ./install.sh --plan       print desired system plan only
EOF
}

confirm_manifest_loop() {
    local editor answer

    editor="${EDITOR:-nano}"

    while true; do
        load_manifest
        validate_manifest
        print_plan

        printf '\n'
        printf 'Continue with this plan? [y]es / [e]dit / [q]uit: '
        read -r answer </dev/tty

        case "$answer" in
            y|Y|yes|YES)
                return 0
                ;;
            e|E|edit|EDIT)
                "$editor" "$MANIFEST_FILE" </dev/tty >/dev/tty 2>&1
                ;;
            q|Q|quit|QUIT)
                exit 0
                ;;
            *)
                warn "Unknown answer: $answer"
                ;;
        esac
    done
}

run_common() {
    require_root
    require_uefi
    load_manifest
    validate_manifest
}

run_live() {
    run_common
    require_arch_iso
    confirm_manifest_loop
    confirm_dangerous_plan
    run_tasks live
}

run_chroot() {
    run_common
    require_network
    run_tasks chroot
}

run_post() {
    run_common
    require_network
    run_tasks post
}

main() {
    case "${1:-}" in
        "")
            run_live
            ;;
        --chroot)
            run_chroot
            ;;
        --post)
            run_post
            ;;
        --plan)
            load_manifest
            validate_manifest
            print_plan
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage >&2
            die "Unknown argument: $1"
            ;;
    esac
}

main "$@"
