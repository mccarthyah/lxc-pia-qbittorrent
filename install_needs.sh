#!/bin/sh
set -e

echo "=== Adding qbittorrent user and home directories ==="
adduser -D -h /home/qbittorrent -s /bin/ash qbittorrent
mkdir -p /home/qbittorrent/.config
mkdir -p /home/qbittorrent/.cache

echo "=== Installing required packages ==="
apk add --no-cache xz screen wireguard-tools qbittorrent-nox git nano ncurses jq iptables curl

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

# === Print final message with system IP for WebUI access ===
SYSTEM_IP=$(ip addr show | awk '/inet / && !/127.0.0.1/ {sub(/\/.*/, "", $2); print $2; exit}')
echo
echo "=============================================="
echo "PIA VPN now active with Port Forwarding,"
echo "connected to the fastest server supporting port forwarding."
echo "You can access the WebUI for qbittorrent at:"
echo "http://${SYSTEM_IP}:8080"
echo "=============================================="
