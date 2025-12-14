#!/usr/bin/env bash
set -e

OPTIONS_FILE="options.env"
CREDS_FILE="credentials.env"

echo "=== Building options.env ==="

# ----------------------------
# Helper function for Y/n → true/false
# ----------------------------
prompt_bool() {
    local prompt="$1"
    local default="$2"
    local answer result

    while :; do
        if [[ "$default" == "true" ]]; then
            read -r -p "$prompt ([Y]/n, default Y): " answer
            answer="${answer:-Y}"
        else
            read -r -p "$prompt ([y]/N, default N): " answer
            answer="${answer:-N}"
        fi

        case "${answer,,}" in
            y|yes) result="true"; break ;;
            n|no)  result="false"; break ;;
            true|false) result="$answer"; break ;;
            *) echo "Please answer y or n." ;;
        esac
    done

    echo "$result"
}

# ----------------------------
# Main options
# ----------------------------
PIA_PF=$(prompt_bool "Enable PIA port forwarding?" "true")

VPN_PROTOCOL="wireguard"
USE_OPENVPN=$(prompt_bool "Use OpenVPN instead of WireGuard?" "false")

if [[ "$USE_OPENVPN" == "true" ]]; then
    echo "Select OpenVPN variant:"
    select vpn_choice in \
        openvpn_udp_standard \
        openvpn_udp_strong \
        openvpn_tcp_standard \
        openvpn_tcp_strong
    do
        [[ -n "$vpn_choice" ]] && VPN_PROTOCOL="$vpn_choice" && break
    done
fi

if [[ "$PIA_PF" == "true" ]]; then
    echo "PIA port forwarding requires WireGuard. Forcing VPN_PROTOCOL=wireguard"
    VPN_PROTOCOL="wireguard"
fi

AUTOCONNECT=$(prompt_bool "Enable auto-connect to server?" "false")
DISABLE_IPV6=$(prompt_bool "Disable IPv6?" "true")
PIA_DNS=$(prompt_bool "Force PIA DNS?" "true")

read -r -p "Enter dedicated IP token (or leave blank): " dip
DIP_TOKEN="${dip:-none}"

if [[ "$AUTOCONNECT" == "true" ]]; then
    PREFERRED_REGION="none"
else
    read -r -p "Enter preferred region (or leave blank): " pref
    PREFERRED_REGION="${pref:-none}"
fi

# ----------------------------
# Credentials (MOVED HERE)
# ----------------------------
echo
echo "=== PIA Credentials ==="

while true; do
    read -rp "PIA username (must start with 'p' and be exactly 8 chars): " PIA_USER
    [[ "$PIA_USER" =~ ^p.{7}$ ]] && break
    echo "Invalid username format."
done

while true; do
    read -rsp "PIA password (at least 8 chars): " PIA_PASS
    echo
    [[ ${#PIA_PASS} -ge 8 ]] && break
    echo "Password too short."
done

# ----------------------------
# Write files
# ----------------------------
cat > "$OPTIONS_FILE" <<EOF
PIA_PF=$PIA_PF
VPN_PROTOCOL=$VPN_PROTOCOL
AUTOCONNECT=$AUTOCONNECT
DISABLE_IPV6=$DISABLE_IPV6
PIA_DNS=$PIA_DNS
DIP_TOKEN=$DIP_TOKEN
PREFERRED_REGION=$PREFERRED_REGION
EOF

cat > "$CREDS_FILE" <<EOF
PIA_USER=$PIA_USER
PIA_PASS=$PIA_PASS
EOF

chmod 600 "$CREDS_FILE"

echo
echo "options.env and credentials.env created successfully."