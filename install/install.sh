#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

# Copyright (c) 2025
# Author: Andrew McCarthy
# License: MIT

APP="PIA qBittorrent (VueTorrent)"
var_disk="8"
var_cpu="2"
var_ram="1024"
var_os="alpine"
var_version="3.20"
var_unprivileged="1"

header_info "$APP"
default_settings
start

msg_info "Updating Alpine"
apk update >/dev/null

msg_info "Installing required packages"
apk add --no-cache \
  xz screen wireguard-tools qbittorrent-nox git nano ncurses jq \
  iptables curl unzip iproute2 >/dev/null

msg_info "Creating qbittorrent user"
adduser -D -h /home/qbittorrent -s /bin/ash qbittorrent
mkdir -p /home/qbittorrent/.config/qBittorrent
mkdir -p /home/qbittorrent/.cache

# --------------------------------------------------
# VueTorrent
# --------------------------------------------------
msg_info "Installing latest VueTorrent release"

VT_DIR="/home/qbittorrent/.config/qBittorrent"
VT_UI_DIR="$VT_DIR/vuetorrent"
VT_ZIP="$VT_DIR/vuetorrent-latest.zip"

TAG=$(curl -s https://api.github.com/repos/VueTorrent/VueTorrent/releases/latest | jq -r .tag_name)
URL="https://github.com/VueTorrent/VueTorrent/releases/download/$TAG/vuetorrent.zip"

rm -rf "$VT_UI_DIR"
mkdir -p "$VT_UI_DIR"

curl -sL "$URL" -o "$VT_ZIP"
unzip -q "$VT_ZIP" -d "$VT_UI_DIR"
rm -f "$VT_ZIP"

chown -R qbittorrent:qbittorrent /home/qbittorrent

msg_ok "VueTorrent $TAG installed"

# --------------------------------------------------
# Install PIA/qBittorrent stack
# --------------------------------------------------
msg_info "Cloning PIA qBittorrent repository"
git clone https://github.com/mccarthyah/lxc-pia-qbittorrent.git /tmp/lxc-pia-qbittorrent

msg_info "Installing service files"
cp -r /tmp/lxc-pia-qbittorrent/etc /tmp/lxc-pia-qbittorrent/opt /

msg_info "Enabling services"
rc-update add microsocks default
rc-update add pia-pf default
rc-update add qbittorrent-set-port default
rc-update add qbittorrent default
rc-update add wg-pia default

msg_info "Configuring qBittorrent WebUI"
cd /tmp/lxc-pia-qbittorrent
./qbt_local_auth.sh
chown -R qbittorrent:qbittorrent /home/qbittorrent

msg_info "Installing microsocks"
cd /opt/pia
./install_microsocks.sh

msg_info "Building VPN configuration"
./build_options.sh
./build.sh

msg_info "Starting services"
service wg-pia start
service pia-pf start
service qbittorrent start
service qbittorrent-set-port start
service microsocks start

SYSTEM_IP=$(ip -4 addr show | awk '/inet/ && !/127/ {sub(/\/.*/, "", $2); print $2; exit}')

msg_ok "Installation complete"
echo
echo "qBittorrent WebUI:"
echo "http://${SYSTEM_IP}:8080"
echo
