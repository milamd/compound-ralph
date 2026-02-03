# Release Script for Ralph with Chronicler

#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Building Ralph with Chronicler support...${NC}"

# Build in release mode
cargo build --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful${NC}"

# Get current directory
RALPH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}") && pwd)"
TARGET_DIR="${RALPH_DIR}/target/release"

# Create ~/.local/bin directory if it doesn't exist
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Create symlink
RALPH_BIN="${LOCAL_BIN}/ralph-chronicler"

if [ -L "$RALPH_BIN" ]; then
    echo -e "${YELLOW}⚠️  Removing existing symlink...${NC}"
    rm "$RALPH_BIN"
fi

ln -sf "$TARGET_DIR/ralph" "$RALPH_BIN"

echo -e "${GREEN}✅ Symlink created: $RALPH_BIN -> $TARGET_DIR/ralph${NC}"

# Verify installation
if "$RALPH_BIN" --version > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Installation verified!${NC}"
    echo ""
    echo -e "${BLUE}📚 Ralph with Chronicler is now available as:${NC}"
    echo -e "   ${GREEN}ralph-chronicler${NC} (symlinked to ~/.local/bin/)"
    echo ""
    echo -e "${YELLOW}💡 Usage examples:${NC}"
    echo -e "   ralph-chronicler --prompt 'Add user authentication'"
    echo -e "   ralph-chronicler hats list --config ralph.yml"
    echo -e "   ralph-chronicler init --preset with-chronicler"
    echo ""
    echo -e "${BLUE}🔄 Added to PATH?${NC}"
    if echo "$PATH" | grep -q "$LOCAL_BIN"; then
        echo -e "   ${GREEN}Yes${NC} - $LOCAL_BIN is in your PATH"
    else
        echo -e "   ${YELLOW}No${NC} - Add to PATH:"
        echo -e "   export PATH=\"\$PATH:$LOCAL_BIN\""
    fi
else
    echo -e "${RED}❌ Installation verification failed${NC}"
    exit 1
fi