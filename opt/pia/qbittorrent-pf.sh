#!/bin/sh
# /opt/pia/qbittorrent-pf.sh
# Check PIA forwarded port and update qBittorrent config if changed
# Uses awk to preserve the literal backslash in "Session\Port="

QB_CONF="/home/qbittorrent/.config/qBittorrent/qBittorrent.conf"
PIA_PORT_FILE="/run/pia-port.txt"
TMP="${QB_CONF}.tmp.$$"

echo "=== Checking qBittorrent port ==="
echo "Config file: $QB_CONF"
echo "PIA port file: $PIA_PORT_FILE"

# existence checks
if [ ! -f "$QB_CONF" ]; then
    echo "Config file not found: $QB_CONF"
    exit 1
fi
if [ ! -f "$PIA_PORT_FILE" ]; then
    echo "PIA port file not found: $PIA_PORT_FILE"
    exit 1
fi

# read current port
CURRENT_PORT=$(grep -m1 '^Session\\Port=' "$QB_CONF" | cut -d= -f2 | tr -cd '0-9')
echo "Current port in config: '$CURRENT_PORT'"

# read & sanitize PIA port
RAW_PIA=$(cat "$PIA_PORT_FILE" 2>/dev/null || true)
PIA_PORT=$(printf '%s' "$RAW_PIA" | tr -cd '0-9')
echo "Raw PIA port: '$(printf '%s' "$RAW_PIA" | cat -v)'"
echo "Sanitized PIA port: '$PIA_PORT'"

if [ -z "$PIA_PORT" ]; then
    echo "No valid PIA port found — aborting."
    exit 1
fi

if [ "$CURRENT_PORT" = "$PIA_PORT" ]; then
    echo "Port is already correct — no update needed."
    exit 0
fi

echo "Port differs, updating config to: $PIA_PORT"

# replace Session\Port= using awk
awk -v newport="$PIA_PORT" '
  BEGIN { replaced = 0 }
  /^Session\\Port=/ {
    print "Session\\Port=" newport
    replaced = 1
    next
  }
  { print }
  END {
    if (replaced == 0) {
      print "Session\\Port=" newport
    }
  }
' "$QB_CONF" > "$TMP" && mv "$TMP" "$QB_CONF" || {
    echo "Failed to update config file."
    rm -f "$TMP"
    exit 1
}

UPDATED=$(grep -m1 '^Session\\Port=' "$QB_CONF" | cut -d= -f2 | tr -cd '0-9')
echo "Config updated. Now Session\\Port='$UPDATED'"

echo "=== Done ==="
exit 0
