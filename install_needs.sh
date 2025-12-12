apk add xz wireguard-tools qbittorrent-nox git nano ncurses jq iptables curl
git clone https://github.com/pia-foss/manual-connections /opt/pia
mv -r etc opt /
cd /etc/init.d
chmod +x microsocks pia-pf pia-port qbittorrent wg-pia
cd /opt/pia
chmod +x build.sh build_options.sh chkip.sh install_microsocks.sh install_needs.sh
rc-update add microsocks default
rc-update add pia-pf default
rc-update add pia-port default
rc-update add qbittorrent default
rc-update add wg-pia default
