#!/usr/bin/env bash

service_file="/etc/systemd/system/custarch-firstboot.service"

log "Configuring firstboot service..."

cat > "$service_file" <<'EOF'
[Unit]
Description=CustArch first boot setup
Wants=network-online.target
After=network-online.target multi-user.target
ConditionPathExists=/opt/custarch/start.sh
ConditionPathExists=/var/lib/custarch/state.env

[Service]
Type=oneshot
WorkingDirectory=/opt/custarch
ExecStart=/opt/custarch/start.sh firstboot
StandardInput=tty-force
StandardOutput=journal+console
StandardError=journal+console
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable custarch-firstboot.service
