apk add xz screen wireguard-tools qbittorrent-nox git nano ncurses jq iptables curl
cp -r etc opt /
rc-update add microsocks default
rc-update add pia-pf default
rc-update add pia-port default
rc-update add qbittorrent default
rc-update add wg-pia default
cd /opt/pia
./build_options.sh
./build.sh
./install_microsocks.sh

