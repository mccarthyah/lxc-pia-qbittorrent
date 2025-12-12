#!/bin/sh
QB_CONF="/home/qbittorrent/.config/qBittorrent/qBittorrent.conf"
PIA_PORT_FILE="/run/pia-port.txt"
TIMEOUT=30

echo "=== DEBUG: Checking qBittorrent port ==="

[ -f "$QB_CONF" ] || { echo "ERROR: Config not found"; exit 1; }
[ -f "$PIA_PORT_FILE" ] || { echo "ERROR: PIA port file not found"; exit 1; }

while [ $TIMEOUT -gt 0 ] && [ ! -s "$PIA_PORT_FILE" ]; do
    echo "Waiting for PIA port file..."
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
done

[ -s "$PIA_PORT_FILE" ] || { echo "ERROR: PIA port file empty"; exit 1; }

PIA_PORT=$(head -n1 "$PIA_PORT_FILE" | tr -cd '0-9')
[ -n "$PIA_PORT" ] || { echo "ERROR: Invalid PIA port"; exit 1; }

echo "Sanitized PIA port: $PIA_PORT"

CURRENT_PORT=$(grep -m1 '^Session\\Port=' "$QB_CONF" | cut -d= -f2 | tr -cd '0-9')
echo "Current qBittorrent port: '$CURRENT_PORT'"

[ "$CURRENT_PORT" != "$PIA_PORT" ] || { echo "Port already correct"; exit 0; }

echo "QB config line before replacement:"
grep -m1 '^Session\\Port=' "$QB_CONF" | od -c

# Use awk to reliably replace
awk -v newport="$PIA_PORT" '
  BEGIN { in_bt=0 }
  /^\[BitTorrent\]/ { in_bt=1; print; next }
  /^\[/ { in_bt=0; print; next }
  { if(in_bt && $0 ~ /^Session\\Port=/) { print "Session\\Port=" newport; next } print }
' "$QB_CONF" > "${QB_CONF}.tmp" && mv "${QB_CONF}.tmp" "$QB_CONF" || {
    echo "ERROR: Failed to update config"; exit 1
}

echo "QB config line after replacement:"
grep -m1 '^Session\\Port=' "$QB_CONF" | od -c

UPDATED=$(grep -m1 '^Session\\Port=' "$QB_CONF" | cut -d= -f2 | tr -cd '0-9')
echo "Config updated. Now Session\\Port='$UPDATED'"

echo "=== Done ==="
exit 0