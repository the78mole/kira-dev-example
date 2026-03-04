#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ps -eo args= | grep -E '(^|[ /])bitbake( |$)|(^|[ /])bitbake-worker( |$)|(^|[ /])bitbake-server( |$)|(^| )kas build( |$)' | grep -v grep >/dev/null 2>&1; then
  echo "Aktive BitBake/KAS-Prozesse erkannt. Bitte zuerst stoppen." >&2
  exit 1
fi

remove_if_exists() {
  local path="$1"
  if [[ -e "${path}" ]]; then
    if mountpoint -q "${path}"; then
      find "${path}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
      echo "Bereinigt (Mountpoint): ${path}"
    else
      rm -rf "${path}"
      echo "Entfernt: ${path}"
    fi
  fi
}

remove_if_exists "${REPO_ROOT}/build"
remove_if_exists "${REPO_ROOT}/openembedded-core"
remove_if_exists "${REPO_ROOT}/TODO.md"

if [[ "${1:-}" == "--tmp" ]]; then
  remove_if_exists "/tmp/bitbake-cache"
  remove_if_exists "/tmp/yocto-downloads"
  remove_if_exists "/tmp/yocto-sstate-cache"
  remove_if_exists "/tmp/yocto-tmp"
  remove_if_exists "/tmp/yocto-xsct"
fi

echo "Cleanup abgeschlossen."
