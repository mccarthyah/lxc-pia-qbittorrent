#!/bin/sh
# install-microsocks.sh
# Downloads and installs precompiled microsocks (ms.xz) on Alpine Linux

set -e

TMPDIR=$(mktemp -d)
BINARY_URL="http://ftp.barfooze.de/pub/sabotage/bin/ms.xz"
INSTALL_PATH="/usr/local/bin/microsocks"

echo "Downloading microsocks binary..."
wget -O "$TMPDIR/ms.xz" "$BINARY_URL"

echo "Decompressing..."
xz -d "$TMPDIR/ms.xz"

# After decompression, the file is "$TMPDIR/ms"
if [ ! -f "$TMPDIR/ms" ]; then
    echo "Error: decompressed binary not found!"
    exit 1
fi

echo "Making executable..."
chmod +x "$TMPDIR/ms"

echo "Installing to $INSTALL_PATH..."
mv "$TMPDIR/ms" "$INSTALL_PATH"

echo "Cleaning up..."
rm -rf "$TMPDIR"

echo "microsocks installed successfully!"
echo "Run it with: microsocks -p 1080"