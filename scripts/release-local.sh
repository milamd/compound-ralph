#!/bin/bash

# Local release script with symlink step for macOS
# Usage: ./scripts/release-local.sh

set -e

echo "Building ralph in release mode..."
cargo build --release

BINARY_PATH="target/release/ralph"
LOCAL_BIN_PATH="$HOME/.local/bin/ralph"

# Check if binary was built successfully
if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    exit 1
fi

echo "Binary built successfully: $BINARY_PATH"

# Create ~/.local/bin directory if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Create symlink if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Creating symlink: $BINARY_PATH -> $LOCAL_BIN_PATH"
    
    # Remove existing symlink if it exists
    if [ -L "$LOCAL_BIN_PATH" ]; then
        echo "Removing existing symlink..."
        rm "$LOCAL_BIN_PATH"
    fi
    
    # Create new symlink
    ln -s "$(pwd)/$BINARY_PATH" "$LOCAL_BIN_PATH"
    echo "Symlink created successfully!"
    
    # Verify symlink works
    if [ -L "$LOCAL_BIN_PATH" ] && [ -x "$LOCAL_BIN_PATH" ]; then
        echo "✓ Symlink is working: $LOCAL_BIN_PATH"
    else
        echo "⚠️  Symlink may not be working correctly"
    fi
else
    echo "Not on macOS. Skipping symlink creation."
    echo "You can manually copy the binary with:"
    echo "cp $BINARY_PATH \$HOME/.local/bin/ralph"
fi

echo "Release complete!"