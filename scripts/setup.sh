#!/usr/bin/env bash
#
# Installer and synchronizer for AI CLI privacy configurations.
# Deploys hardened settings for Anthropic Claude Code and Google Antigravity CLI.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

#######################################
# Creates destination directories if they do not already exist.
# Globals:
#   HOME
# Arguments:
#   None
#######################################
create_required_directories() {
  mkdir -p "${HOME}/.claude"
  mkdir -p "${HOME}/.gemini/antigravity-cli"
  mkdir -p "${HOME}/src"
}

#######################################
# Deploys unified master ignore rules and establishes symlinks.
# Globals:
#   HOME
#   REPO_ROOT
# Arguments:
#   None
#######################################
deploy_master_ignore_rules() {
  echo "Deploying master ignore rules..."
  cp "${REPO_ROOT}/ignore-rules/.claudeignore" "${HOME}/src/.claudeignore"
  ln -sf "${HOME}/src/.claudeignore" "${HOME}/src/.geminiignore"
  ln -sf "${HOME}/src/.claudeignore" "${HOME}/src/.aiexclude"
  echo "  ✓ Installed: ${HOME}/src/.claudeignore"
  echo "  ✓ Linked: ${HOME}/src/.geminiignore"
  echo "  ✓ Linked: ${HOME}/src/.aiexclude"
}

#######################################
# Configures Claude Code privacy rules and creates backup.
# Globals:
#   HOME
#   REPO_ROOT
#   TIMESTAMP
# Arguments:
#   None
#######################################
configure_claude_settings() {
  echo "Configuring Claude Code privacy settings..."
  local claude_dest="${HOME}/.claude/settings.json"
  if [[ -f "${claude_dest}" ]]; then
    echo "  Backing up existing Claude settings to ${claude_dest}.bak_${TIMESTAMP}"
    cp "${claude_dest}" "${claude_dest}.bak_${TIMESTAMP}"
  fi
  cp "${REPO_ROOT}/claude/settings.json" "${claude_dest}"
  chmod 600 "${claude_dest}"
  echo "  ✓ Applied: ${claude_dest} (permissions: 600)"
}

#######################################
# Configures Antigravity CLI privacy rules and creates backup.
# Globals:
#   HOME
#   REPO_ROOT
#   TIMESTAMP
# Arguments:
#   None
#######################################
configure_antigravity_settings() {
  echo "Configuring Antigravity CLI privacy settings..."
  local antigravity_dest="${HOME}/.gemini/antigravity-cli/settings.json"
  if [[ -f "${antigravity_dest}" ]]; then
    echo "  Backing up existing Antigravity settings to ${antigravity_dest}.bak_${TIMESTAMP}"
    cp "${antigravity_dest}" "${antigravity_dest}.bak_${TIMESTAMP}"
  fi
  cp "${REPO_ROOT}/antigravity/settings.json" "${antigravity_dest}"
  chmod 600 "${antigravity_dest}"
  echo "  ✓ Applied: ${antigravity_dest} (permissions: 600)"
}

#######################################
# Main routine executing sequential setup tasks.
# Arguments:
#   Script arguments passed through.
#######################################
main() {
  echo "=========================================================="
  echo "  AI CLI Privacy Configuration Installer (macOS)"
  echo "  Targeting Claude Code & Antigravity CLI"
  echo "=========================================================="
  echo ""

  create_required_directories
  deploy_master_ignore_rules
  echo ""
  configure_claude_settings
  echo ""
  configure_antigravity_settings

  echo ""
  echo "=========================================================="
  echo "  Setup Complete"
  echo "=========================================================="
  echo "To enable 'ai-lock' and 'ai-audit' in your terminal, add"
  echo "the following line to your ~/.zshrc or ~/.bash_profile:"
  echo ""
  echo "  source \"\${HOME}/src/ai-cli-privacy-config/shell/ai-privacy.zsh\""
  echo ""
}

main "$@"
