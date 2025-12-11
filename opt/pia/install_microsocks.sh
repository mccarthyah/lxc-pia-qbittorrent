#!/bin/sh
# install-microsocks.sh
# Downloads and installs precompiled microsocks on Alpine Linux

set -e

MICROSOCKS_VERSION="1.0.2"
ARCH=$(uname -m)
TMPDIR=$(mktemp -d)
BINARY_URL="http://ftp.barfooze.de/pub/sabotage/tarballs/microsocks-${MICROSOCKS_VERSION}-${ARCH}-static.xz"
INSTALL_PATH="/usr/local/bin/microsocks"

echo "Downloading microsocks v${MICROSOCKS_VERSION} for ${ARCH}..."
wget -O "$TMPDIR/microsocks.xz" "$BINARY_URL"

echo "Decompressing..."
xz -d "$TMPDIR/microsocks.xz"

echo "Making executable..."
chmod +x "$TMPDIR/microsocks"

echo "Installing to $INSTALL_PATH..."
mv "$TMPDIR/microsocks" "$INSTALL_PATH"

echo "Cleaning up..."
rm -rf "$TMPDIR"

echo "microsocks installed successfully!"
echo "Run it with: microsocks -p 1080"
