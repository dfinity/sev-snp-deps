#!/usr/bin/env bash

set -eo pipefail

SOURCE_DIR="${SOURCE_DIR:-}"
if [[ -z "${SOURCE_DIR}" ]]; then
    echo "missing SOURCE_DIR"
    exit 1
fi

OUT_DIR="${OUT_DIR:-}"
if [[ -z "${OUT_DIR}" ]]; then
    echo "missing OUT_DIR"
    exit 1
fi

# See https://github.com/AMDESE/AMDSEV/issues/124#issuecomment-1336387966
# See https://github.com/kata-containers/kata-containers/blob/CCv0/tools/packaging/static-build/ovmf/build-ovmf.sh#L53
touch OvmfPkg/AmdSev/Grub/grub.efi

# Build
make -C BaseTools
source edksetup.sh --reconfig

build \
    --arch="X64" \
    --platform="OvmfPkg/AmdSev/AmdSevX64.dsc" \
    --tagname="GCC5" \
    -n $(nproc)

# Output
cp "${SOURCE_DIR}/Build/AmdSev/DEBUG_GCC5/FV/OVMF.fd" "${OUT_DIR}"