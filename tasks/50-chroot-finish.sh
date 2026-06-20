#!/usr/bin/env bash

run_chroot() {
    cat <<EOF

Chroot work is done.
After reboot, run:
  sudo $TARGET_DIR/install.sh --post
EOF
}
