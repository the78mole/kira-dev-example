#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KAS_FILE="${KAS_FILE:-kas/k26-smk.yml}"

: "${ACCEPT_XILINX_LICENSE:=0}"
if [[ "${ACCEPT_XILINX_LICENSE}" != "1" ]]; then
  echo "Xilinx-Lizenz nicht bestätigt."
  echo "Setze ACCEPT_XILINX_LICENSE=1, um den Build zu starten."
  exit 2
fi

: "${KIRA_BITBAKE_CACHE_DIR:=/tmp/bitbake-cache}"
: "${DL_DIR:=/tmp/yocto-downloads}"
: "${SSTATE_DIR:=/tmp/yocto-sstate-cache}"
: "${TMPDIR:=/tmp/yocto-tmp}"
: "${XSCT_STAGING_DIR:=/tmp/yocto-xsct}"
: "${XSCT_DLDIR:=${DL_DIR}/xsct}"

mkdir -p \
  "${KIRA_BITBAKE_CACHE_DIR}" \
  "${DL_DIR}" \
  "${SSTATE_DIR}" \
  "${TMPDIR}" \
  "${XSCT_STAGING_DIR}" \
  "${XSCT_DLDIR}"

export LICENSE_FLAGS_ACCEPTED="${LICENSE_FLAGS_ACCEPTED:-} xilinx"

echo "Starte Build mit:"
echo "  KAS_FILE=${KAS_FILE}"
echo "  KIRA_BITBAKE_CACHE_DIR=${KIRA_BITBAKE_CACHE_DIR}"
echo "  DL_DIR=${DL_DIR}"
echo "  SSTATE_DIR=${SSTATE_DIR}"
echo "  TMPDIR=${TMPDIR}"
echo "  XSCT_STAGING_DIR=${XSCT_STAGING_DIR}"

echo
cd "${REPO_ROOT}"
KIRA_BITBAKE_CACHE_DIR="${KIRA_BITBAKE_CACHE_DIR}" \
DL_DIR="${DL_DIR}" \
SSTATE_DIR="${SSTATE_DIR}" \
TMPDIR="${TMPDIR}" \
XSCT_STAGING_DIR="${XSCT_STAGING_DIR}" \
XSCT_DLDIR="${XSCT_DLDIR}" \
LICENSE_FLAGS_ACCEPTED="${LICENSE_FLAGS_ACCEPTED}" \
kas build "${KAS_FILE}"
