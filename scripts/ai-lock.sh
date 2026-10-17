#!/usr/bin/env bash
#
# Attaches unified AI privacy and exclusion rules to a target workspace.
# Creates symbolic links for .claudeignore, .geminiignore, and .aiexclude.

set -euo pipefail

#######################################
# Resolves the master ignore file location.
# Globals:
#   HOME
# Arguments:
#   Repository directory path.
# Outputs:
#   Path to valid master ignore file.
#######################################
resolve_master_ignore() {
  local repo_dir="$1"
  local candidate="${repo_dir}/ignore-rules/.claudeignore"

  if [[ -f "${candidate}" ]]; then
    echo "${candidate}"
    return 0
  fi

  if [[ -f "${HOME}/src/.claudeignore" ]]; then
    echo "${HOME}/src/.claudeignore"
    return 0
  fi

  echo "Master ignore rule file not found at ${candidate} or ${HOME}/src/.claudeignore" >&2
  return 1
}

#######################################
# Main routine to link ignore files into the target directory.
# Arguments:
#   Target directory path (optional, defaults to current working directory).
#######################################
main() {
  local target_dir="${1:-$(pwd)}"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local repo_dir
  repo_dir="$(cd "${script_dir}/.." && pwd)"

  local source_file
  source_file="$(resolve_master_ignore "${repo_dir}")"

  echo "Applying AI privacy ignore locks to: ${target_dir}"

  ln -sf "${source_file}" "${target_dir}/.claudeignore"
  ln -sf "${source_file}" "${target_dir}/.geminiignore"
  ln -sf "${source_file}" "${target_dir}/.aiexclude"

  echo "Workspace privacy lock established successfully:"
  echo "  -> ${target_dir}/.claudeignore"
  echo "  -> ${target_dir}/.geminiignore"
  echo "  -> ${target_dir}/.aiexclude"
}

main "$@"
