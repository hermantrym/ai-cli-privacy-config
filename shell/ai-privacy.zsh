#!/usr/bin/env zsh
# ==============================================================================
# AI CLI Privacy & Security Shell Integration
# macOS / Zsh environment helpers for Claude Code & Antigravity CLI
# ==============================================================================

# Default repository and ignore source path
export AI_PRIVACY_ROOT="${AI_PRIVACY_ROOT:-$HOME/src/ai-cli-privacy-config}"
export AI_IGNORE_SOURCE="${AI_PRIVACY_ROOT}/ignore-rules/.claudeignore"

# Helper alias/function to lock down current project workspace by creating
# standardized AI ignore symlinks (.claudeignore, .geminiignore, .aiexclude)
ai-lock() {
  local target_dir="${1:-$(pwd)}"
  local source_file="${AI_IGNORE_SOURCE}"

  if [[ ! -f "$source_file" ]]; then
    # Fallback to local source in ~/src if exists
    if [[ -f "$HOME/src/.claudeignore" ]]; then
      source_file="$HOME/src/.claudeignore"
    else
      echo "\033[0;31m[ERROR]\033[0m Master ignore rule file not found at $source_file" >&2
      return 1
    fi
  fi

  echo "\033[0;34m[INFO]\033[0m Enforcing AI privacy locks in: $target_dir"
  ln -sf "$source_file" "$target_dir/.claudeignore" && \
  ln -sf "$source_file" "$target_dir/.geminiignore" && \
  ln -sf "$source_file" "$target_dir/.aiexclude"

  if [[ $? -eq 0 ]]; then
    echo "\033[0;32m[SUCCESS]\033[0m AI security ignore files successfully linked:"
    echo "  -> .claudeignore"
    echo "  -> .geminiignore"
    echo "  -> .aiexclude"
  else
    echo "\033[0;31m[ERROR]\033[0m Failed to create symlinks." >&2
    return 1
  fi
}

# Helper function to audit current repository for potential sensitive leaks
ai-audit() {
  echo "\033[0;34m[AUDIT]\033[0m Inspecting current workspace for sensitive files..."
  local found=0
  local patterns=(".env*" "*.pem" "*.key" "*.p12" "*.pfx" "*.p8" "*.jks" "*.keystore" "*service-account*.json" "*secret*" "*credential*")

  for pattern in "${patterns[@]}"; do
    local matches
    matches=$(find . -maxdepth 3 -name "$pattern" ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" 2>/dev/null)
    if [[ -n "$matches" ]]; then
      echo "\033[0;33m[WARN]\033[0m Potential secret files detected matching '$pattern':"
      echo "$matches" | sed 's/^/  - /'
      found=$((found + 1))
    fi
  done

  if [[ ! -f ".claudeignore" && ! -f ".geminiignore" ]]; then
    echo "\033[0;31m[ALERT]\033[0m No AI ignore file (.claudeignore / .geminiignore) found in this folder!"
    echo "Run 'ai-lock' to protect this workspace."
  elif [[ $found -eq 0 ]]; then
    echo "\033[0;32m[PASS]\033[0m No obvious unignored secrets detected in workspace root (depth 3)."
  fi
}
