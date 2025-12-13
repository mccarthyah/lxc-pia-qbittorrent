#!/usr/bin/env bash

wg-quick down pia

# === Load options ===
if [[ -f options.env ]]; then
    source options.env
fi

# === Load credentials ===
if [[ -f credentials.env ]]; then
    source credentials.env
else
    echo "Creating credentials.env for PIA login..."
    read -rp "PIA username (p#######): " PIA_USER
    read -rsp "PIA password: " PIA_PASS
    echo
    echo "PIA_USER=$PIA_USER" > credentials.env
    echo "PIA_PASS=$PIA_PASS" >> credentials.env
fi

# === Export credentials ===
export PIA_USER
export PIA_PASS

# === Export all options ===
export AUTOCONNECT
export VPN_PROTOCOL
export PIA_PF
export DISABLE_IPV6
export PREFERRED_REGION
export DIP_TOKEN
export PIA_DNS

# === Debug printout ===
echo "Using configuration from options.env:"
echo "AUTOCONNECT=$AUTOCONNECT"
echo "VPN_PROTOCOL=$VPN_PROTOCOL"
echo "PIA_PF=$PIA_PF"
echo "DISABLE_IPV6=$DISABLE_IPV6"
echo "PREFERRED_REGION=$PREFERRED_REGION"
echo "DIP_TOKEN=$DIP_TOKEN"
echo "PIA_DNS=$PIA_DNS"

# === Run the setup script in the background ===
./run_setup.sh &
SETUP_PID=$!

echo "run_setup.sh started with PID $SETUP_PID. It will be killed after 1 minute."

# === Wait 1 minute ===
sleep 60

# === Kill the setup script ===
kill $SETUP_PID 2>/dev/null || true
echo "run_setup.sh (PID $SETUP_PID) has been killed."
