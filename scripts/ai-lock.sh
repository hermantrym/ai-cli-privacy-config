#!/usr/bin/env bash
# ==============================================================================
# ai-lock.sh
# Quickly attach AI privacy and exclusion rules to the target workspace
# ==============================================================================

set -euo pipefail

TARGET_DIR="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_FILE="${REPO_DIR}/ignore-rules/.claudeignore"

if [[ ! -f "${SOURCE_FILE}" ]]; then
  if [[ -f "$HOME/src/.claudeignore" ]]; then
    SOURCE_FILE="$HOME/src/.claudeignore"
  else
    echo -e "\033[0;31m[ERROR]\033[0m Master ignore rule file not found at ${SOURCE_FILE}" >&2
    exit 1
  fi
fi

echo -e "\033[0;34m[INFO]\033[0m Applying AI privacy ignore locks to: ${TARGET_DIR}"

ln -sf "${SOURCE_FILE}" "${TARGET_DIR}/.claudeignore"
ln -sf "${SOURCE_FILE}" "${TARGET_DIR}/.geminiignore"
ln -sf "${SOURCE_FILE}" "${TARGET_DIR}/.aiexclude"

echo -e "\033[0;32m[OK]\033[0m Workspace privacy lock established successfully:"
echo "     -> ${TARGET_DIR}/.claudeignore"
echo "     -> ${TARGET_DIR}/.geminiignore"
echo "     -> ${TARGET_DIR}/.aiexclude"
