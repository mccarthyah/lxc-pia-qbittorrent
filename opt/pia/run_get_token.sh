#!/bin/sh
# Launch get_token.sh using credentials from credentials.env

CRED_FILE="/opt/pia/credentials.env"

# Make sure the file exists
if [ ! -f "$CRED_FILE" ]; then
    echo "Credentials file not found: $CRED_FILE"
    exit 1
fi

# Load credentials
. "$CRED_FILE"

if [ -z "$PIA_USER" ] || [ -z "$PIA_PASS" ]; then
    echo "PIA_USER or PIA_PASS missing in $CRED_FILE"
    exit 1
fi

# Run get_token.sh with credentials
PIA_USER="$PIA_USER" PIA_PASS="$PIA_PASS" /opt/pia/get_token.sh
