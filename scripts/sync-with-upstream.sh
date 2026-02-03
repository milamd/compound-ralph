#!/bin/bash
# Rebase this repository against the main branch of the parent repository
# Usage: ./scripts/sync-with-upstream.sh [--force]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Parse arguments
FORCE_REBASE=false
if [[ "$1" == "--force" ]]; then
    FORCE_REBASE=true
fi

cd "$REPO_ROOT"

echo "🔄 Syncing with upstream repository..."
echo ""

# Check if we have uncommitted changes
if [[ -n $(git status --porcelain) ]] && [[ "$FORCE_REBASE" != true ]]; then
    echo "❌ You have uncommitted changes. Please commit or stash them first."
    echo "   Use --force to override this check (not recommended)."
    exit 1
fi

# Ensure upstream remote exists and is correct
if ! git remote get-url upstream > /dev/null 2>&1; then
    echo "❌ Upstream remote not found. Adding it..."
    git remote add upstream https://github.com/mikeyobrien/ralph-orchestrator.git
fi

# Fetch latest changes from upstream
echo "📥 Fetching latest changes from upstream..."
git fetch upstream

# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" == "HEAD" ]]; then
    echo "❌ You appear to be in a detached HEAD state. Please check out a branch first."
    exit 1
fi

echo "📍 Current branch: $CURRENT_BRANCH"
echo "📍 Upstream branch: main"
echo ""

# Check if there are any upstream changes
LOCAL_COMMIT=$(git rev-parse "upstream/main")
REMOTE_COMMIT=$(git rev-parse "upstream/main@{upstream}")

if [[ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]]; then
    echo "✅ Already up to date with upstream."
    exit 0
fi

# Show what will be rebased
echo "📋 Changes that will be rebased:"
git log --oneline upstream/main..HEAD || echo "  (no local commits to rebase)"
echo ""

# Confirm before proceeding
if [[ "$FORCE_REBASE" != true ]]; then
    read -p "Continue with rebase? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Rebase cancelled."
        exit 1
    fi
fi

# Perform the rebase
echo "🔄 Performing rebase..."
if git rebase upstream/main; then
    echo ""
    echo "✅ Rebase completed successfully!"
    echo ""
    echo "📊 Summary:"
    echo "  • Your local commits have been rebased on top of upstream/main"
    echo "  • No conflicts occurred"
    echo ""
    echo "🚀 You can now push with: git push --force-with-lease"
else
    echo ""
    echo "❌ Rebase encountered conflicts."
    echo ""
    echo "🔧 To resolve conflicts:"
    echo "  1. Fix the conflicted files"
    echo "  2. git add <resolved-files>"
    echo "  3. git rebase --continue"
    echo "  4. Or abort with: git rebase --abort"
    exit 1
fi