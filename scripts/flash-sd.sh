#!/usr/bin/env bash
# flash-sd.sh – Write a Yocto .wic image to an SD card
#
# Usage:
#   ./scripts/flash-sd.sh <image.wic[.bz2|.gz|.zst]> <device>
#
# Examples:
#   ./scripts/flash-sd.sh build/tmp/deploy/images/k26-smk/petalinux-image-minimal-k26-smk.wic /dev/sdb
#   ./scripts/flash-sd.sh build/tmp/deploy/images/k26-smk/petalinux-image-minimal-k26-smk.wic.bz2 /dev/sdb
#
# WARNING: This script will ERASE ALL DATA on the target device.
#          Double-check the device path before running.

set -euo pipefail

# ── Argument validation ───────────────────────────────────────────────────────
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <image.wic[.bz2|.gz|.zst]> <target-device>"
    exit 1
fi

IMAGE="$1"
DEVICE="$2"

if [[ ! -f "${IMAGE}" ]]; then
    echo "ERROR: Image file '${IMAGE}' not found."
    exit 1
fi

if [[ ! -b "${DEVICE}" ]]; then
    echo "ERROR: '${DEVICE}' is not a block device."
    exit 1
fi

# ── Safety check: refuse to flash a mounted device ───────────────────────────
if grep -qs "${DEVICE}" /proc/mounts; then
    echo "ERROR: ${DEVICE} is currently mounted. Unmount it first."
    exit 1
fi

# ── Confirm before proceeding ────────────────────────────────────────────────
echo "⚠️  WARNING: All data on ${DEVICE} will be permanently erased."
read -r -p "Type 'yes' to continue: " CONFIRM
if [[ "${CONFIRM}" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

# ── Write the image ──────────────────────────────────────────────────────────
echo "🔄 Flashing ${IMAGE} to ${DEVICE} ..."

case "${IMAGE}" in
    *.bz2)
        bzcat "${IMAGE}" | sudo dd of="${DEVICE}" bs=4M conv=fsync status=progress
        ;;
    *.gz)
        zcat "${IMAGE}" | sudo dd of="${DEVICE}" bs=4M conv=fsync status=progress
        ;;
    *.zst)
        zstdcat "${IMAGE}" | sudo dd of="${DEVICE}" bs=4M conv=fsync status=progress
        ;;
    *.wic)
        sudo dd if="${IMAGE}" of="${DEVICE}" bs=4M conv=fsync status=progress
        ;;
    *)
        echo "ERROR: Unrecognised image format. Expected .wic, .wic.bz2, .wic.gz, or .wic.zst"
        exit 1
        ;;
esac

sudo sync
echo "✅ Done. SD card is ready. Safely remove ${DEVICE}."
