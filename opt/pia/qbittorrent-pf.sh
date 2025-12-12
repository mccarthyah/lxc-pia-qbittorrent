#!/bin/sh
QB_CONF="/home/qbittorrent/.config/qBittorrent/qBittorrent.conf"
PIA_PORT_FILE="/run/pia-port.txt"

echo "=== Checking qBittorrent port ==="

# Ensure files exist
[ -f "$QB_CONF" ] || { echo "Config file not found: $QB_CONF"; exit 1; }
[ -f "$PIA_PORT_FILE" ] || { echo "PIA port file not found: $PIA_PORT_FILE"; exit 1; }

# Read and sanitize PIA port
PIA_PORT=$(tr -cd '0-9' < "$PIA_PORT_FILE")
[ -n "$PIA_PORT" ] || { echo "No valid PIA port found — aborting."; exit 1; }

# Replace Session\Port= only inside [Bittorrent] section
# Handles literal backslash and leading spaces, ignores line endings
sed -i "/^\[Bittorrent\]/,/^\[/{ 
    s/^\([[:space:]]*Session\\\\Port=\).*/\1$PIA_PORT/
}" "$QB_CONF" || { echo "Failed to update config"; exit 1; }

# Show updated value
UPDATED=$(grep -m1 -E '^[[:space:]]*Session\\Port=' "$QB_CONF" | cut -d= -f2 | tr -cd '0-9')
echo "Config updated. Now Session\\Port='$UPDATED'"

echo "=== Done ==="
exit 0