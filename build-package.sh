#!/bin/bash
# Build script to create a .plasmoid package for Pling/KDE Store

set -e

PACKAGE_NAME="epoch"
VERSION=$(grep '"Version"' metadata.json | sed 's/.*"\([0-9.]*\)".*/\1/')

echo "Building ${PACKAGE_NAME} v${VERSION}..."

# Create temporary build directory
BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT

# Copy plasmoid files to build directory
cp -r contents "$BUILD_DIR/"
cp metadata.json "$BUILD_DIR/"

# Create the .plasmoid archive (it's just a zip file with .plasmoid extension)
cd "$BUILD_DIR"
zip -r "${PACKAGE_NAME}-${VERSION}.plasmoid" contents metadata.json

# Move the package back to the repo
mv "${PACKAGE_NAME}-${VERSION}.plasmoid" "$OLDPWD/"

echo "Package created: ${PACKAGE_NAME}-${VERSION}.plasmoid"
echo ""
echo "To install locally:"
echo "  kpackagetool6 --type Plasma/Applet --install ${PACKAGE_NAME}-${VERSION}.plasmoid"
echo ""
echo "To upload to Pling:"
echo "  1. Go to https://store.kde.org/"
echo "  2. Upload ${PACKAGE_NAME}-${VERSION}.plasmoid"
