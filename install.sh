#!/bin/bash

# Installation script for HEICFormat Photoshop Plugin

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}HEICFormat Plugin Installer${NC}"
echo "============================"
echo ""

# Default values
BUILD_DIR="build"
ADOBE_PLUGIN_DIR="/Library/Application Support/Adobe/Plug-Ins/CC/File Formats"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Installs the HEICFormat plugin to the shared Adobe plugin directory."
            echo "This location works for ALL Adobe Photoshop versions automatically."
            echo ""
            echo "Install location:"
            echo "  ${ADOBE_PLUGIN_DIR}"
            echo ""
            echo "Note: This script requires sudo privileges."
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Installing to shared Adobe plugin directory..."
echo -e "${BLUE}Location:${NC} ${ADOBE_PLUGIN_DIR}"
echo ""

# Check if plugin was built
if [ ! -d "${BUILD_DIR}/HEICFormat.plugin" ]; then
    echo -e "${RED}Error: Plugin not found at ${BUILD_DIR}/HEICFormat.plugin${NC}"
    echo ""
    echo "Please build the plugin first:"
    echo -e "  ${YELLOW}./build.sh${NC}"
    exit 1
fi

echo -e "${BLUE}Plugin:${NC} ${BUILD_DIR}/HEICFormat.plugin"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}This script needs sudo privileges to install the plugin.${NC}"
    echo "Please enter your password when prompted."
    echo ""
    
    # Re-run this script with sudo
    sudo "$0"
    exit $?
fi

# Create Adobe plugin directory if it doesn't exist
echo "Creating Adobe plugin directory if needed..."
mkdir -p "$ADOBE_PLUGIN_DIR"

PLUGIN_PATH="${ADOBE_PLUGIN_DIR}/HEICFormat.plugin"

# Remove old plugin if it exists
if [ -d "$PLUGIN_PATH" ]; then
    echo "Removing old plugin..."
    rm -rf "$PLUGIN_PATH"
fi

# Copy plugin
echo "Installing plugin..."
cp -R "${BUILD_DIR}/HEICFormat.plugin" "$ADOBE_PLUGIN_DIR/"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to copy plugin${NC}"
    exit 1
fi

# Set permissions and code sign
echo "Setting permissions and code signing..."
xattr -cr "$PLUGIN_PATH" 2>/dev/null
chmod -R a+rX "$PLUGIN_PATH" 2>/dev/null
chmod a+x "$PLUGIN_PATH/Contents/MacOS/HEICFormat" 2>/dev/null

# Code sign with runtime for Apple Silicon compatibility
codesign --force --deep --sign - --options runtime "$PLUGIN_PATH" 2>/dev/null || echo "  Warning: Code signing failed (plugin may still work)"

# Verify installation
if [ -d "$PLUGIN_PATH" ]; then
    echo ""
    echo "================================"
    echo -e "${GREEN}✓ Installation successful!${NC}"
    echo "================================"
    echo ""
    echo "Plugin installed at:"
    echo "  $PLUGIN_PATH"
    echo ""
    echo -e "${GREEN}This plugin will work with ALL Adobe Photoshop versions!${NC}"
    echo ""
    echo -e "${YELLOW}Please restart Adobe Photoshop${NC} for the plugin to take effect."
    echo ""
    echo "After restarting Photoshop:"
    echo "  1. Check 'Help > About Plug-ins > HEIC Format' to verify installation"
    echo "  2. Try 'File > Save As' and look for 'HEIC Format' in the format list"
else
    echo -e "${RED}✗ Installation failed: Plugin not found after copying${NC}"
    exit 1
fi

