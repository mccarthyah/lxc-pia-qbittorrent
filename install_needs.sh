#!/bin/sh
set -e

echo "=== Adding qbittorrent user and home directories ==="
adduser -D -h /home/qbittorrent -s /bin/ash qbittorrent
mkdir -p /home/qbittorrent/.config/qBittorrent
mkdir -p /home/qbittorrent/.cache

echo "=== Installing required packages ==="
apk add --no-cache \
    xz screen wireguard-tools qbittorrent-nox git nano ncurses jq \
    iptables curl unzip

# --------------------------------------------------
# Download latest VueTorrent release
# --------------------------------------------------
echo "=== Downloading latest VueTorrent release ==="

VT_DIR="/home/qbittorrent/.config/qBittorrent"
VT_UI_DIR="$VT_DIR/vuetorrent"
VT_ZIP="$VT_DIR/vuetorrent-latest.zip"

# Get latest tag name
TAG=$(curl -s https://api.github.com/repos/VueTorrent/VueTorrent/releases/latest \
    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

echo "Latest VueTorrent tag: $TAG"

# Construct download URL
URL="https://github.com/VueTorrent/VueTorrent/releases/download/$TAG/vuetorrent.zip"

# Clean old UI
rm -rf "$VT_UI_DIR"
mkdir -p "$VT_UI_DIR"

# Download and extract
curl -sL "$URL" -o "$VT_ZIP"
unzip -q "$VT_ZIP" -d "$VT_UI_DIR"
rm -f "$VT_ZIP"

chown -R qbittorrent:qbittorrent /home/qbittorrent

echo "VueTorrent installed to $VT_UI_DIR"

# --------------------------------------------------
# Clone repo files
# --------------------------------------------------
echo "=== Cloning repo files to LXC ==="
git clone https://github.com/mccarthyah/lxc-pia-qbittorrent.git
cd lxc-pia-qbittorrent

echo "=== Copying repo files into LXC filesystem ==="
cp -r etc opt /

echo "=== Activating services in default runlevel ==="
rc-update add microsocks default
rc-update add pia-pf default
rc-update add qbittorrent-set-port default
rc-update add qbittorrent default
rc-update add wg-pia default

echo "=== Setting up qbittorrent local auth ==="
./qbt_local_auth.sh
chown -R qbittorrent:qbittorrent /home/qbittorrent

echo "=== Entering /opt/pia for further setup ==="
cd /opt/pia

echo "=== Installing microsocks ==="
./install_microsocks.sh

echo "=== Creating VPN and port forwarding settings ==="
./build_options.sh
./build.sh

echo "=== Starting services ==="
service wg-pia start
service pia-pf start
service qbittorrent start
service qbittorrent-set-port start
service microsocks start
rc-status

echo "=== Setup complete ==="

# --------------------------------------------------
# Final access message
# --------------------------------------------------
SYSTEM_IP=$(ip addr show | awk '/inet / && !/127.0.0.1/ {sub(/\/.*/, "", $2); print $2; exit}')

echo
echo "=============================================="
echo "PIA VPN now active with Port Forwarding,"
echo "connected to the fastest server supporting port forwarding."
echo "You can access the WebUI for qbittorrent at:"
echo "http://${SYSTEM_IP}:8080"
echo "=============================================="