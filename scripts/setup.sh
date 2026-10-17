#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Installer & Synchronizer for AI CLI Privacy Configurations
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo "=========================================================="
echo "  AI CLI Privacy Configuration Installer (macOS)"
echo "  Targeting Claude Code & Antigravity CLI"
echo "=========================================================="

# 1. Ensure directories exist
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.gemini/antigravity-cli"
mkdir -p "$HOME/src"

# 2. Master Ignore Rules deployment
echo ""
echo "[Step 1/3] Deploying Master Ignore Rules..."
cp "${REPO_ROOT}/ignore-rules/.claudeignore" "$HOME/src/.claudeignore"
ln -sf "$HOME/src/.claudeignore" "$HOME/src/.geminiignore"
ln -sf "$HOME/src/.claudeignore" "$HOME/src/.aiexclude"
echo "  ✓ Installed: $HOME/src/.claudeignore"
echo "  ✓ Linked: $HOME/src/.geminiignore"
echo "  ✓ Linked: $HOME/src/.aiexclude"

# 3. Claude Code Privacy Settings
echo ""
echo "[Step 2/3] Configuring Claude Code Privacy Settings..."
CLAUDE_DEST="$HOME/.claude/settings.json"
if [[ -f "$CLAUDE_DEST" ]]; then
  echo "  Backing up existing Claude settings to $CLAUDE_DEST.bak_${TIMESTAMP}"
  cp "$CLAUDE_DEST" "$CLAUDE_DEST.bak_${TIMESTAMP}"
fi
cp "${REPO_ROOT}/claude/settings.json" "$CLAUDE_DEST"
chmod 600 "$CLAUDE_DEST"
echo "  ✓ Applied: $CLAUDE_DEST (permissions: 600)"

# 4. Antigravity CLI Privacy Settings
echo ""
echo "[Step 3/3] Configuring Antigravity CLI Privacy Settings..."
ANTIGRAVITY_DEST="$HOME/.gemini/antigravity-cli/settings.json"
if [[ -f "$ANTIGRAVITY_DEST" ]]; then
  echo "  Backing up existing Antigravity settings to $ANTIGRAVITY_DEST.bak_${TIMESTAMP}"
  cp "$ANTIGRAVITY_DEST" "$ANTIGRAVITY_DEST.bak_${TIMESTAMP}"
fi
cp "${REPO_ROOT}/antigravity/settings.json" "$ANTIGRAVITY_DEST"
chmod 600 "$ANTIGRAVITY_DEST"
echo "  ✓ Applied: $ANTIGRAVITY_DEST (permissions: 600)"

# 5. Shell Integration Notice
echo ""
echo "=========================================================="
echo "  Setup Complete!"
echo "=========================================================="
echo "To enable 'ai-lock' and 'ai-audit' in your terminal, add"
echo "the following line to your ~/.zshrc or ~/.bash_profile:"
echo ""
echo "  source \"${REPO_ROOT}/shell/ai-privacy.zsh\""
echo ""
