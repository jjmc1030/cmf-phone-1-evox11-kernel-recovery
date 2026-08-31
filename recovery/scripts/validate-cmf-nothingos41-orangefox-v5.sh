#!/usr/bin/env bash
set -euo pipefail

ROOT="${CMF_BUILD_ROOT:?Set CMF_BUILD_ROOT to the project build workspace}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export CMF_ORANGEFOX_OUT="${CMF_ORANGEFOX_OUT:-$ROOT/outputs/NothingOS-4.1-B4.1-260812-1726/recovery}"
export CMF_ORANGEFOX_IMAGE="$CMF_ORANGEFOX_OUT/CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-OrangeFox-R12.0-v5-MinimalPlatform-TouchProviderOrder-EarlyADB-vendor_boot.img"
export CMF_ORANGEFOX_PROFILE=nothingos41-touchfix

exec "$SCRIPT_DIR/validate-cmf-nothingos41-orangefox-v3.sh"
