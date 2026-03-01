#!/usr/bin/env zsh

# Script to create CLAUDE.md symlinks to AGENTS.md files
# This allows CLAUDE.md files to exist locally without being committed to git
# https://solmaz.io/log/2025/09/08/claude-md-agents-md-migration-guide/

set -euo pipefail

echo "Setting up CLAUDE.md symlinks..."

# Change to repository root
if ! REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "Error: must be run from within a git repository" >&2
  exit 1
fi
cd "$REPO_ROOT"

# Find all tracked AGENTS.md files (grep exit 1 = no matches, not an error)
AGENTS_FILES=$(git ls-files | grep "AGENTS\.md$" || true)

if [[ -z "$AGENTS_FILES" ]]; then
  echo "No tracked AGENTS.md files found — nothing to symlink"
  echo "(Tip: git add your AGENTS.md files first)"
  exit 0
fi

while IFS= read -r file; do
    dir=$(dirname "$file")
    claude_file="${file/AGENTS.md/CLAUDE.md}"

    # Remove existing CLAUDE.md file/link if it exists
    if [[ -e "$claude_file" || -L "$claude_file" ]]; then
        rm "$claude_file"
        echo "Removed existing $claude_file"
    fi

    # Create symlink
    if [[ "$dir" == "." ]]; then
        ln -s "AGENTS.md" "CLAUDE.md"
        echo "Created symlink: CLAUDE.md -> AGENTS.md"
    else
        ln -s "AGENTS.md" "$claude_file"
        echo "Created symlink: $claude_file -> AGENTS.md"
    fi
done <<< "$AGENTS_FILES"

# Ensure CLAUDE.md is ignored by git
GITIGNORE="$REPO_ROOT/.gitignore"
if [[ ! -f "$GITIGNORE" ]] || ! grep -qF "CLAUDE.md" "$GITIGNORE"; then
    echo "CLAUDE.md" >> "$GITIGNORE"
    echo "Added CLAUDE.md to .gitignore"
fi

echo ""
echo "✓ CLAUDE.md symlinks setup complete!"
echo "  - CLAUDE.md files are ignored by git"
echo "  - They will automatically stay in sync with AGENTS.md files"
echo "  - Run this script again if you add new AGENTS.md files"
echo "  - If .gitignore was updated, remember to commit it"
