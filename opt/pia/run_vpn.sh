#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# Bring down WireGuard if running
# --------------------------------------------------
if command -v wg-quick >/dev/null 2>&1; then
    wg-quick down pia 2>/dev/null || true
fi

# --------------------------------------------------
# Load configuration
# --------------------------------------------------
if [[ ! -f options.env ]]; then
    echo "ERROR: options.env not found. Run build_options.sh first."
    exit 1
fi

if [[ ! -f credentials.env ]]; then
    echo "ERROR: credentials.env not found. Run build_options.sh first."
    exit 1
fi

source options.env
source credentials.env

export PIA_USER PIA_PASS
export AUTOCONNECT VPN_PROTOCOL PIA_PF DISABLE_IPV6
export PREFERRED_REGION DIP_TOKEN PIA_DNS

# --------------------------------------------------
# Debug output (no secrets)
# --------------------------------------------------
echo "Using configuration:"
echo "AUTOCONNECT=$AUTOCONNECT"
echo "VPN_PROTOCOL=$VPN_PROTOCOL"
echo "PIA_PF=$PIA_PF"
echo "DISABLE_IPV6=$DISABLE_IPV6"
echo "PREFERRED_REGION=$PREFERRED_REGION"
echo "DIP_TOKEN=$DIP_TOKEN"
echo "PIA_DNS=$PIA_DNS"

# --------------------------------------------------
# Run setup
# --------------------------------------------------
if [[ ! -x ./run_setup.sh ]]; then
    echo "Error: run_setup.sh not found or not executable!"
    exit 1
fi

./run_setup.sh
