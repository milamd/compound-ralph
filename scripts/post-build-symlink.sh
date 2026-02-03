#!/bin/bash

# Post-build script for cargo-dist to create symlink on macOS
# This script is called after the binary is built

set -e

BINARY_PATH="$1"
TARGET_DIR="$2"
ARCH="$3"

# Only create symlink for local builds (not CI)
if [ -z "$CI" ] && [[ "$OSTYPE" == "darwin"* ]]; then
    LOCAL_BIN_PATH="$HOME/.local/bin/ralph"
    
    echo "Creating macOS local symlink..."
    
    # Create ~/.local/bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    
    # Remove existing symlink if it exists
    if [ -L "$LOCAL_BIN_PATH" ]; then
        rm "$LOCAL_BIN_PATH"
    fi
    
    # Create symlink to the built binary
    if [ -f "$BINARY_PATH" ]; then
        ln -s "$BINARY_PATH" "$LOCAL_BIN_PATH"
        echo "✓ Symlink created: $BINARY_PATH -> $LOCAL_BIN_PATH"
    else
        echo "Warning: Binary not found at $BINARY_PATH"
    fi
fi