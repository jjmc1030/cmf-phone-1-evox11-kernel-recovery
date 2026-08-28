#!/bin/sh
set -eu

# Rebuild the final CMF Phone 1 Evolution X 11.10 feature kernel.
# Usage: ./build-cmf-evox-featurepack-suexecfix-v4-kernel.sh [work-directory]

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
KERNEL_PUBLISH_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
BUILD_ROOT=${1:-"$PWD/cmf-evox-featurepack-33252-build"}
COMMON_DIR="$BUILD_ROOT/common"
KSU_DIR="$BUILD_ROOT/KernelSU-Next-susfs"
TOOLCHAIN_ROOT="$BUILD_ROOT/clang-prebuilt"
OUT_DIR="$BUILD_ROOT/out"

COMMON_TAG=android14-6.1-2025-05_r1
COMMON_COMMIT=8dc7d7757edd922ed1e79851711dc2c47bfcf227
KSU_COMMIT=1ce76ef55805697fcfa56aa18fb8dacd06b0dafb
COMMON_PATCH_FILE="$KERNEL_PUBLISH_DIR/patches/CMF-Phone-1-EvolutionX-11.10-FeaturePack-KSUNext-SUSFS-SUExecFix-v3-source.patch"
KSU_PATCH_FILE="$KERNEL_PUBLISH_DIR/patches/CMF-Phone-1-EvolutionX-11.10-KSUNext-33252-SUSFS-SUExecFix-v4.patch"
CONFIG_FILE="$KERNEL_PUBLISH_DIR/config/CMF-Phone-1-EvolutionX-11.10-FeaturePack-WiFiFix.config"

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

if ! git -C "$KSU_DIR" diff --quiet HEAD; then
    echo "KernelSU tree already has local changes; refusing to patch it." >&2
    exit 1
fi
git -C "$KSU_DIR" apply "$KSU_PATCH_FILE"

if ! git -C "$COMMON_DIR" diff --quiet HEAD; then
    echo "Kernel tree already has local changes; refusing to patch it." >&2
    exit 1
fi
git -C "$COMMON_DIR" apply "$COMMON_PATCH_FILE"

if [ -n "${CLANG_DIR:-}" ]; then
    TOOLCHAIN_BIN="$CLANG_DIR/bin"
else
    if [ ! -d "$TOOLCHAIN_ROOT/.git" ]; then
        git clone --depth=1 --branch llvm-r487747 \
            https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 \
            "$TOOLCHAIN_ROOT"
    fi
    TOOLCHAIN_BIN="$TOOLCHAIN_ROOT/clang-r487747b/bin"
fi
test -x "$TOOLCHAIN_BIN/clang"

mkdir -p "$OUT_DIR"
cp "$CONFIG_FILE" "$OUT_DIR/.config"

export PATH="$TOOLCHAIN_BIN:$PATH"
export KBUILD_BUILD_USER=build-user
export KBUILD_BUILD_HOST=build-host
export KBUILD_BUILD_VERSION=4
export KBUILD_BUILD_TIMESTAMP='Thu Jan 1 00:00:00 UTC 1970'

make -C "$COMMON_DIR" O="$OUT_DIR" ARCH=arm64 LLVM=1 LLVM_IAS=1 \
    LOCALVERSION= olddefconfig
make -C "$COMMON_DIR" O="$OUT_DIR" ARCH=arm64 LLVM=1 LLVM_IAS=1 \
    LOCALVERSION= -j"$(getconf _NPROCESSORS_ONLN)" Image modules

test "$(cat "$OUT_DIR/include/config/kernel.release")" = "6.1.134-android14-11"
grep -q '^CONFIG_ARCH_MEDIATEK=y$' "$OUT_DIR/.config"
grep -q '^CONFIG_CFG80211=m$' "$OUT_DIR/.config"
grep -q '^CONFIG_MAC80211=m$' "$OUT_DIR/.config"
grep -q '^CONFIG_KSU=y$' "$OUT_DIR/.config"
grep -q '^CONFIG_KSU_SUSFS=y$' "$OUT_DIR/.config"
grep -q '^CONFIG_BBG=y$' "$OUT_DIR/.config"
grep -q '^CONFIG_TCP_CONG_BBR3=y$' "$OUT_DIR/.config"
grep -q 'KSU_VERSION=33252' "$OUT_DIR/drivers/kernelsu/feature/.sucompat.o.cmd"

lz4 -l -12 -f "$OUT_DIR/arch/arm64/boot/Image" "$BUILD_ROOT/Image.lz4"
sha256sum "$OUT_DIR/arch/arm64/boot/Image" "$BUILD_ROOT/Image.lz4"
echo "Built KernelSU Next 33252 image: $BUILD_ROOT/Image.lz4"
