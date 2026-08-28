#!/bin/sh
set -eu

# Rebuild the CMF Phone 1 Evolution X 11.10 GKI kernel.
# Usage: ./build-cmf-evox-kernel.sh [work-directory]

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BUILD_ROOT=${1:-"$PWD/cmf-evox-kernel-build"}
COMMON_DIR="$BUILD_ROOT/common"
KSU_DIR="$BUILD_ROOT/KernelSU-Next-susfs"
TOOLCHAIN_ROOT="$BUILD_ROOT/clang-prebuilt"
OUT_DIR="$BUILD_ROOT/out"

COMMON_TAG=android14-6.1-2025-05_r1
COMMON_COMMIT=8dc7d7757edd922ed1e79851711dc2c47bfcf227
KSU_COMMIT=26fded805206ae4542f4745e09cc465412994492
PATCH_FILE="$SCRIPT_DIR/CMF-Phone-1-EvolutionX-11.10-KSUNext-SUSFS-source.patch"

mkdir -p "$BUILD_ROOT"

if [ ! -d "$COMMON_DIR/.git" ]; then
    git clone --depth=1 --branch "$COMMON_TAG" \
        https://android.googlesource.com/kernel/common "$COMMON_DIR"
fi
test "$(git -C "$COMMON_DIR" rev-parse HEAD)" = "$COMMON_COMMIT"

if [ ! -d "$KSU_DIR/.git" ]; then
    git clone --depth=1 --branch dev-susfs \
        https://github.com/pershoot/KernelSU-Next.git "$KSU_DIR"
    git -C "$KSU_DIR" fetch --depth=1 origin "$KSU_COMMIT"
    git -C "$KSU_DIR" checkout "$KSU_COMMIT"
fi
test "$(git -C "$KSU_DIR" rev-parse HEAD)" = "$KSU_COMMIT"

if ! git -C "$COMMON_DIR" diff --quiet -- drivers/Makefile; then
    echo "Kernel tree already has local changes; refusing to apply the patch twice." >&2
    exit 1
fi
git -C "$COMMON_DIR" apply "$PATCH_FILE"

if [ -n "${CLANG_DIR:-}" ]; then
    TOOLCHAIN_BIN="$CLANG_DIR/bin"
else
    if [ ! -d "$TOOLCHAIN_ROOT/.git" ]; then
        echo "Downloading the pinned AOSP Clang bundle (about 18 GB checked out)..."
        git clone --depth=1 --branch llvm-r487747 \
            https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 \
            "$TOOLCHAIN_ROOT"
    fi
    TOOLCHAIN_BIN="$TOOLCHAIN_ROOT/clang-r487747b/bin"
fi
test -x "$TOOLCHAIN_BIN/clang"

export PATH="$TOOLCHAIN_BIN:$PATH"
export KBUILD_BUILD_USER=build-user
export KBUILD_BUILD_HOST=build-host
export KBUILD_BUILD_VERSION=1
export KBUILD_BUILD_TIMESTAMP='Thu Jan 1 00:00:00 UTC 1970'

make -C "$COMMON_DIR" O="$OUT_DIR" ARCH=arm64 LLVM=1 LLVM_IAS=1 \
    LOCALVERSION= gki_defconfig
make -C "$COMMON_DIR" O="$OUT_DIR" ARCH=arm64 LLVM=1 LLVM_IAS=1 \
    LOCALVERSION= -j"$(getconf _NPROCESSORS_ONLN)" Image modules

test "$(cat "$OUT_DIR/include/config/kernel.release")" = "6.1.134-android14-11"
lz4 -l -12 -f "$OUT_DIR/arch/arm64/boot/Image" "$BUILD_ROOT/Image.lz4"
sha256sum "$BUILD_ROOT/Image.lz4"
echo "Built: $BUILD_ROOT/Image.lz4"
