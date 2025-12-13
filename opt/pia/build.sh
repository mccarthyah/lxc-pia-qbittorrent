#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# Bring down WireGuard if running
# --------------------------------------------------
if command -v wg-quick >/dev/null 2>&1; then
    wg-quick down pia 2>/dev/null || true
fi

# --------------------------------------------------
# Load options.env if present
# --------------------------------------------------
if [[ -f options.env ]]; then
    source options.env
fi

# --------------------------------------------------
# Load or prompt for PIA credentials with validation
# --------------------------------------------------
load_credentials() {
    if [[ -f credentials.env ]]; then
        source credentials.env
    fi

    # Username: exactly 8 chars, must start with 'p'
    while true; do
        if [[ -z "${PIA_USER:-}" ]] || [[ ! "$PIA_USER" =~ ^p.{7}$ ]]; then
            read -rp "PIA username (must start with 'p' and be exactly 8 chars): " PIA_USER
            continue
        fi
        break
    done

    # Password: at least 8 chars
    while true; do
        if [[ -z "${PIA_PASS:-}" ]] || [[ ${#PIA_PASS} -lt 8 ]]; then
            read -rsp "PIA password (at least 8 chars): " PIA_PASS
            echo
            continue
        fi
        break
    done

    # Save credentials safely
    echo "PIA_USER=$PIA_USER" > credentials.env
    echo "PIA_PASS=$PIA_PASS" >> credentials.env
    chmod 600 credentials.env
}

load_credentials

# --------------------------------------------------
# Export credentials
# --------------------------------------------------
export PIA_USER
export PIA_PASS

# --------------------------------------------------
# Export all options
# --------------------------------------------------
export AUTOCONNECT
export VPN_PROTOCOL
export PIA_PF
export DISABLE_IPV6
export PREFERRED_REGION
export DIP_TOKEN
export PIA_DNS

# --------------------------------------------------
# Debug printout
# --------------------------------------------------
echo "Using configuration from options.env:"
echo "AUTOCONNECT=$AUTOCONNECT"
echo "VPN_PROTOCOL=$VPN_PROTOCOL"
echo "PIA_PF=$PIA_PF"
echo "DISABLE_IPV6=$DISABLE_IPV6"
echo "PREFERRED_REGION=$PREFERRED_REGION"
echo "DIP_TOKEN=$DIP_TOKEN"
echo "PIA_DNS=$PIA_DNS"

# --------------------------------------------------
# Run the setup script in the background
# --------------------------------------------------
if [[ ! -x ./run_setup.sh ]]; then
    echo "Error: run_setup.sh not found or not executable!"
    exit 1
fi

./run_setup.sh &
SETUP_PID=$!
echo "run_setup.sh started with PID $SETUP_PID. It will be killed after 1 minute."

# Wait 1 minute
sleep 60

# Kill the setup script
if kill -0 $SETUP_PID 2>/dev/null; then
    kill $SETUP_PID 2>/dev/null || true
    echo "run_setup.sh (PID $SETUP_PID) has been killed."
else
    echo "run_setup.sh already exited."
fi