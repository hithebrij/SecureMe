#!/bin/bash

# SecureMe Installer & Updater
# Author: Brijendra Pratap Singh

SCRIPT_NAME="secureme.sh"
REMOTE_URL="https://github.com/hithebrij/SecureMe/blob/main/secureme.sh"  # or GitHub raw URL
INSTALL_DIR="/usr/local/bin"
BACKUP_DIR="$HOME/.secureme_backup"

echo "🔄 Installing or Updating SecureMe..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup existing version if exists
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    echo "📦 Backing up existing version to $BACKUP_DIR"
    cp "$INSTALL_DIR/$SCRIPT_NAME" "$BACKUP_DIR/$SCRIPT_NAME.bak_$(date +%Y%m%d%H%M%S)"
fi

# Download the latest script
echo "⬇️ Downloading latest version..."
curl -fsSL "$REMOTE_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"

# Make executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Confirm success
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    echo "✅ SecureMe installed/updated at $INSTALL_DIR/$SCRIPT_NAME"
else
    echo "❌ Installation failed. Check URL or permissions."
    exit 1
fi

# Ask to run now
read -p "🚀 Do you want to run SecureMe now? (y/n): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    sudo "$INSTALL_DIR/$SCRIPT_NAME"
fi
