apk add xz screen wireguard-tools qbittorrent-nox git nano ncurses jq iptables curl
cp -r etc opt /
rc-update add microsocks default
rc-update add pia-pf default
rc-update add pia-port default
rc-update add qbittorrent default
rc-update add wg-pia default
adduser -D -s /bin/ash qbittorrent
mkdir -p /home/qbittorrent
mkdir -p /home/qbittorrent/.config
mkdir -p /home/qbittorrent/.cache
chown -R qbittorrent:qbittorrent /home/qbittorrent



cd /opt/pia
./install_microsocks.sh
./build_options.sh
./build.sh


