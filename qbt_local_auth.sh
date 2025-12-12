#!/bin/ash

CONF_DIR="/home/qbittorrent/.config/qBittorrent"
CONF_FILE="$CONF_DIR/qBittorrent.conf"

# ---------- Detect local subnet (/24) ----------
# Get the first non-loopback IPv4 address
IP=$(ip -4 addr show | awk '/inet/ && $2 !~ /^127/ {print $2; exit}' | cut -d/ -f1)

# Convert to /24
SUBNET=$(echo "$IP" | awk -F. '{printf "%s.%s.%s.0/24", $1, $2, $3}')

echo "Detected subnet: $SUBNET"

# ---------- Ensure config structure ----------
mkdir -p "$CONF_DIR"
touch "$CONF_FILE"
chown -R qbittorrent:qbittorrent /home/qbittorrent

# Add [Preferences] if missing
if ! grep -q "^\[Preferences\]" "$CONF_FILE"; then
    echo "" >> "$CONF_FILE"
    echo "[Preferences]" >> "$CONF_FILE"
fi

# ---------- Rewrite Preferences section safely ----------
awk -v SUBNET="$SUBNET" '
BEGIN {
    new1 = "WebUI\\AuthSubnetWhitelist=" SUBNET;
    new2 = "WebUI\\AuthSubnetWhitelistEnabled=true";
    new3 = "WebUI\\LocalHostAuth=false";
}

/^\[Preferences\]/ {
    print;
    in_pref = 1;

    # Insert new settings immediately after [Preferences]
    print new1
    print new2
    print new3

    next
}

in_pref && /^\[/ { in_pref = 0 }

/^WebUI\\AuthSubnetWhitelist=/ { if(in_pref) next }
/^WebUI\\AuthSubnetWhitelistEnabled=/ { if(in_pref) next }
/^WebUI\\LocalHostAuth=/ { if(in_pref) next }

{ print }
' "$CONF_FILE" > "$CONF_FILE.tmp"

mv "$CONF_FILE.tmp" "$CONF_FILE"
chown qbittorrent:qbittorrent "$CONF_FILE"
