# Add qbittorrent user and folder
adduser -D -h /home/qbittorrent -s /bin/ash qbittorrent

# Add necessary apps
apk add xz screen wireguard-tools qbittorrent-nox git nano ncurses jq iptables curl

# Copy repo files into LXC filesystem
cp -r etc opt /

# Activate services into Default runlevel
rc-update add microsocks default
rc-update add pia-pf default
rc-update add qbittorrent-set-port default
rc-update add qbittorrent default
rc-update add wg-pia default

# Ensure all user options and folders exist and are accessible
adduser -D -h /home/qbittorrent -s /bin/ash qbittorrent
mkdir -p /home/qbittorrent
mkdir -p /home/qbittorrent/.config
mkdir -p /home/qbittorrent/.cache

# Added locsl auth settings in qbittorrent settings
./qbt_local_auth.sh
chown -R qbittorrent:qbittorrent /home/qbittorrent

# Entering folder for setup
cd /opt/pia

# Installing microsocks
./install_microsocks.sh

# Create settings for VPN and port forwarding setup
./build_options.sh
./build.sh

# Start services
service wg-pia start
service pia-pf start
service qbittorrent start
service qbittorrent-set-port start
service microsocks start



