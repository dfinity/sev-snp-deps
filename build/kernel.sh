#!/usr/bin/env bash

set -euo pipefail

BUILD_DIR=/tmp/build
CONFIG_CMD="scripts/config --file ${BUILD_DIR}/.config"

CONFIG_PATH="${CONFIG_PATH:-}"
if [[ -z "${CONFIG_PATH}" ]]; then
    echo "missing CONFIG_PATH"
    exit 1
fi

OUT_DIR="${OUT_DIR:-}"
if [[ -z "${OUT_DIR}" ]]; then
    echo "missing OUT_DIR"
    exit 1
fi

# Clean up
make O=${BUILD_DIR} distclean

# Configuration
cp "${CONFIG_PATH}" "${BUILD_DIR}/.config"

# Build and package
make O=${BUILD_DIR} -j$(nproc) bindeb-pkg

# Extract kernel and generate initrd
find "${BUILD_DIR}/.." -name "linux-image*.deb" -not -name "*dbg*" -exec dpkg -i {} \;

# Output
find "${BUILD_DIR}/.." -name "linux-image*.deb" -not -name "*dbg*" | xargs -I {} cp {} "${OUT_DIR}"
find "/boot" -name "initrd*" -or -name "vmlinuz*" -or -name "config*" | xargs -I {} cp {} "${OUT_DIR}"
