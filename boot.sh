#!/usr/bin/env bash
set -euo pipefail


#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/sdrtba/CustArch/refs/heads/main/"
ARCHIVE="custarch.tar.gz"
ARCHIVE_URL="$BASE_URL/$ARCHIVE"
WORKDIR="/tmp/custarch"
LOGFILE="/tmp/custarch-install.log"

exec > >(tee -a "$LOGFILE") 2>&1

echo "[*] Starting bootstrap..."

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

echo "[*] Downloading project archive..."
curl -fsSL "$ARCHIVE_URL" -o /tmp/$ARCHIVE

echo "[*] Extracting archive..."
tar -xzf /tmp/$ARCHIVE -C /tmp

chmod +x "$WORKDIR"/stages/*.sh
chmod +x "$WORKDIR"/chroot/*.sh
chmod +x "$WORKDIR"/lib/*.sh

echo "[*] Running stage 01..."
bash "$WORKDIR/stages/01-partition.sh"

echo "[*] Running stage 02..."
bash "$WORKDIR/stages/02-format-mount.sh"

echo "[*] Running stage 03..."
bash "$WORKDIR/stages/03-pacstrap.sh"

echo "[*] Running stage 04..."
bash "$WORKDIR/stages/04-run-chroot.sh"

echo "[*] Installation steps finished."
echo "[*] Log saved to $LOGFILE"
