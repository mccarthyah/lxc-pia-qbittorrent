Private Internet Access VPN with Port Forwarding running on a slim Alpine LXC

Proxmox Alpine LXC
Static IP recommended

Storage for media to be configured after (recommend "mount point")

Installation commands

wget -O install_needs.sh https://raw.githubusercontent.com/mccarthyah/lxc-pia-qbittorrent/refs/heads/main/install_needs.sh
chmod +x install_needs.sh
./install_needs.sh

Local authentication is disabled for localhost and local subnet. Forwarded port will be updated as necessary with the web API. A microsocks socks5 proxy is running on port 1080 with no authentication. 

Please use at your own risk. I am not a programmer, just a sledgehammer hobbyist. Any suggestions are welcomed. 
