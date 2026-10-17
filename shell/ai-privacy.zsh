#!/usr/bin/env zsh
#
# Shell integration helpers for AI CLI privacy and data governance.
# Provides commands to enforce workspace lockouts and inspect sensitive files.

# Resolves root directory of privacy repository and fallback paths.
export AI_PRIVACY_ROOT="${AI_PRIVACY_ROOT:-${HOME}/src/ai-cli-privacy-config}"
export AI_IGNORE_SOURCE="${AI_PRIVACY_ROOT}/ignore-rules/.claudeignore"

#######################################
# Hardens current or target workspace by symlinking master ignore definitions.
# Globals:
#   AI_IGNORE_SOURCE
#   HOME
# Arguments:
#   Target directory path (optional, defaults to current directory).
# Returns:
#   Returns zero on success, non-zero on failure.
#######################################
ai-lock() {
  local target_dir="${1:-$(pwd)}"
  local source_file="${AI_IGNORE_SOURCE}"

  if [[ ! -f "${source_file}" ]]; then
    if [[ -f "${HOME}/src/.claudeignore" ]]; then
      source_file="${HOME}/src/.claudeignore"
    else
      echo "Master ignore rule file not found at ${source_file}" >&2
      return 1
    fi
  fi

  echo "Enforcing AI privacy locks in: ${target_dir}"
  ln -sf "${source_file}" "${target_dir}/.claudeignore" && \
  ln -sf "${source_file}" "${target_dir}/.geminiignore" && \
  ln -sf "${source_file}" "${target_dir}/.aiexclude"

  if [[ $? -eq 0 ]]; then
    echo "AI security ignore files successfully linked:"
    echo "  -> .claudeignore"
    echo "  -> .geminiignore"
    echo "  -> .aiexclude"
  else
    echo "Failed to create symlinks." >&2
    return 1
  fi
}

#######################################
# Audits current workspace directory for common exposed secret patterns.
# Arguments:
#   None
# Returns:
#   Returns zero upon completing inspection.
#######################################
ai-audit() {
  echo "Inspecting current workspace for sensitive files..."
  local found=0
  local patterns=(".env*" "*.pem" "*.key" "*.p12" "*.pfx" "*.p8" "*.jks" "*.keystore" "*service-account*.json" "*secret*" "*credential*")

  for pattern in "${patterns[@]}"; do
    local matches
    matches=$(find . -maxdepth 3 -name "${pattern}" ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" 2>/dev/null)
    if [[ -n "${matches}" ]]; then
      echo "Potential secret files detected matching '${pattern}':"
      echo "${matches}" | sed 's/^/  - /'
      found=$((found + 1))
    fi
  done

  if [[ ! -f ".claudeignore" && ! -f ".geminiignore" ]]; then
    echo "No AI ignore file (.claudeignore / .geminiignore) found in this folder!"
    echo "Run 'ai-lock' to protect this workspace."
  elif [[ "${found}" -eq 0 ]]; then
    echo "No obvious unignored secrets detected in workspace root (depth 3)."
  fi
}
