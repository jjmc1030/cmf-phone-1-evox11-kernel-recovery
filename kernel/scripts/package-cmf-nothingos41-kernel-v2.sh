#!/usr/bin/env bash
set -euo pipefail

ROOT="${CMF_BUILD_ROOT:?Set CMF_BUILD_ROOT to the project build workspace}"
ROM="${NOTHINGOS41_ROM_DIR:?Set NOTHINGOS41_ROM_DIR to the extracted Nothing OS 4.1 package}"
WORK="$ROOT/work/nothingos41"
SRC="$WORK/src-common-6.1.162"
BUILD="$WORK/out-kernel-v2"
OUT="${CMF_OUTPUT_DIR:-$ROOT/outputs/NothingOS-4.1-B4.1-260812-1726/kernel}"
MAGISKBOOT="$ROOT/work/bootimg-tools/magiskboot"
AVBTOOL="$ROOT/work/bootimg-tools/avb/avbtool.py"
AVB_KEY="$ROOT/work/bootimg-tools/avb/test/data/testkey_rsa2048.pem"
KERNEL="$BUILD/arch/arm64/boot/Image"
KERNEL_CONFIG="$BUILD/.config"
STOCK_CERT="$SRC/certs/nothingos41-stock-module-signing.x509"
BUILT_CERT="$BUILD/certs/x509_certificate_list"
PARTITION_SIZE=67108864
BOOT_SALT="b16a0ade6b083b84412dbb52857e7116386b9ca2633d8fd4fab1a7d6372b2e62"
BOOT_FINGERPRINT="alps/hal_mgvi_64_64only_ww_armv82/mgvi_64_64only_ww_armv82:14/UP1A.231005.007/2608121726:user/release-keys"
KERNEL_NAME="CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-FeaturePack-v2-StockModuleTrustFix-KSUNext-33252-SUSFS-2.2.0-boot.img"
RESTORE_NAME="CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-OFFICIAL-RESTORE-boot.img"

mkdir -p "$OUT"
PACKAGE_TEMP=$(mktemp -d "$WORK/package-kernel-v2.XXXXXX")
trap 'rm -rf "$PACKAGE_TEMP"' EXIT

for required in "$ROM/boot.img" "$MAGISKBOOT" "$AVBTOOL" "$AVB_KEY" \
  "$KERNEL" "$KERNEL_CONFIG" "$STOCK_CERT" "$BUILT_CERT"; do
    test -f "$required" || { echo "Missing input: $required" >&2; exit 1; }
done

test "$(cat "$BUILD/include/config/kernel.release")" = "6.1.162-android14-11"
cmp -s "$STOCK_CERT" "$BUILT_CERT" || {
    echo "Built trusted certificate does not match the stock module signer." >&2
    exit 1
}

for option in CONFIG_KSU=y CONFIG_KSU_SUSFS=y CONFIG_BBG=y \
  CONFIG_TCP_CONG_BBR3=y CONFIG_WIREGUARD=y CONFIG_NET_SCH_CAKE=y \
  CONFIG_NTSYNC=y CONFIG_BPF_UNPRIV_DEFAULT_OFF=y \
  CONFIG_MODULE_SIG_PROTECT=y; do
    grep -qx "$option" "$KERNEL_CONFIG" || {
        echo "Required kernel option is missing: $option" >&2
        exit 1
    }
done
grep -qx 'CONFIG_SYSTEM_TRUSTED_KEYS="certs/nothingos41-stock-module-signing.pem"' "$KERNEL_CONFIG"

BOOT_WORK="$PACKAGE_TEMP/boot"
mkdir -p "$BOOT_WORK/verify"
(
    cd "$BOOT_WORK"
    "$MAGISKBOOT" unpack "$ROM/boot.img"
    cp "$KERNEL" kernel
    "$MAGISKBOOT" repack "$ROM/boot.img" unsigned.img
)

cp "$BOOT_WORK/unsigned.img" "$BOOT_WORK/verify/boot.img"
python3 "$AVBTOOL" erase_footer --image "$BOOT_WORK/verify/boot.img"
python3 "$AVBTOOL" add_hash_footer \
  --image "$BOOT_WORK/verify/boot.img" \
  --partition_size "$PARTITION_SIZE" \
  --partition_name boot \
  --algorithm SHA256_RSA2048 \
  --key "$AVB_KEY" \
  --salt "$BOOT_SALT" \
  --prop com.android.build.boot.os_version:14 \
  --prop "com.android.build.boot.fingerprint:$BOOT_FINGERPRINT" \
  --prop com.android.build.boot.security_patch:2026-04-05
python3 "$AVBTOOL" verify_image --image "$BOOT_WORK/verify/boot.img"

cp "$BOOT_WORK/verify/boot.img" "$OUT/$KERNEL_NAME"
cp "$ROM/boot.img" "$OUT/$RESTORE_NAME"
cp "$KERNEL_CONFIG" "$OUT/CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-FeaturePack-v2.config"
cp "$STOCK_CERT" "$OUT/NothingOS-4.1-stock-module-signing-public.x509"
lz4 -l -12 -f "$KERNEL" "$OUT/CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-FeaturePack-v2-Image.lz4"

test "$(stat -c %s "$OUT/$KERNEL_NAME")" -eq "$PARTITION_SIZE"

FINAL_CHECK="$PACKAGE_TEMP/final-check"
mkdir -p "$FINAL_CHECK"
(
    cd "$FINAL_CHECK"
    "$MAGISKBOOT" unpack "$OUT/$KERNEL_NAME"
    cmp -s kernel "$KERNEL"
)

echo "Packaged Nothing OS 4.1 FeaturePack kernel v2 in $OUT"
