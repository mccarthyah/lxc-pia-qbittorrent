#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# Utility functions
# --------------------------------------------------
log_info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

# --------------------------------------------------
# Bring down WireGuard if already running
# --------------------------------------------------
if command -v wg-quick >/dev/null 2>&1; then
    log_info "Bringing down WireGuard interface 'pia' if exists..."
    wg-quick down pia 2>/dev/null || true
fi

# --------------------------------------------------
# Load options.env safely
# --------------------------------------------------
if [[ -f options.env ]]; then
    log_info "Loading options from options.env..."
    source options.env
else
    log_warn "options.env not found, continuing with defaults..."
fi

# --------------------------------------------------
# Load or prompt for PIA credentials
# --------------------------------------------------
load_credentials() {
    if [[ -f credentials.env ]]; then
        source credentials.env
    fi

    # Username: exactly 8 chars, start with 'p'
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
    log_info "Credentials saved to credentials.env"
}

load_credentials

# Export for child scripts
export PIA_USER
export PIA_PASS

# --------------------------------------------------
# Validate options variables
# --------------------------------------------------
validate_option() {
    local name="$1"
    local val="${!name:-}"
    local required="$2"

    if [[ "$required" == "true" ]] && [[ -z "$val" ]]; then
        log_error "Required option '$name' is missing in options.env"
        exit 1
    fi
}

for var in AUTOCONNECT VPN_PROTOCOL PIA_PF DISABLE_IPV6 PREFERRED_REGION DIP_TOKEN PIA_DNS; do
    validate_option "$var" false
done

# Export all options
export AUTOCONNECT VPN_PROTOCOL PIA_PF DISABLE_IPV6 PREFERRED_REGION DIP_TOKEN PIA_DNS

# --------------------------------------------------
# Debug print
#