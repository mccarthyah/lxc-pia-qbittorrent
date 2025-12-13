#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Andrew McCarthy (mccarthyah)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/mccarthyah/lxc-pia-qbittorrent

APP="PIA VPN QBT"
var_tags="${var_tags:-alpine;auth}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-alpine}"
var_version="${var_version:-3.22}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  if [[ ! -d /opt/pia ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Updating packages"
  $STD apk -U upgrade
  msg_ok "Updated packages"

    msg_info "Installing VPN and Torrent System"
    wget -O install_needs.sh https://raw.githubusercontent.com/mccarthyah/lxc-pia-qbittorrent/refs/heads/main/install_needs.sh
    chmod +x install_needs.sh
    ./install_needs.sh
    msg_ok "Installed and Torrent"

  exit 0
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} setup has been successfully initialized!"
