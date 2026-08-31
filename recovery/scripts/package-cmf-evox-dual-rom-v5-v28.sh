#!/usr/bin/env bash
set -euo pipefail

ROOT="${CMF_BUILD_ROOT:?Set CMF_BUILD_ROOT to the project build workspace}"
OUTPUTS="${CMF_OUTPUT_DIR:?Set CMF_OUTPUT_DIR to the package output directory}"
MAGISKBOOT="$ROOT/work/bootimg-tools/magiskboot"
AVBTOOL="$ROOT/work/bootimg-tools/avb/avbtool.py"
AVB_KEY="$ROOT/work/bootimg-tools/avb/test/data/testkey_rsa2048.pem"
KERNEL="$ROOT/work/out-featurepack-33252/arch/arm64/boot/Image"
KERNEL_CONFIG="$ROOT/work/out-featurepack-33252/.config"
RECOVERY_RAMDISK="$ROOT/work/twrp/orangefox16-source/out/target/product/Tetris/obj/PACKAGING/vendor_ramdisk_fragments_intermediates/recovery.cpio.lz4"
GAPPS_BOOT="${EVOX_GAPPS_BOOT:?Set EVOX_GAPPS_BOOT to build 2447 boot.img}"
VANILLA_BOOT="${EVOX_VANILLA_BOOT:?Set EVOX_VANILLA_BOOT to build 2446 boot.img}"
GAPPS_VENDOR_BOOT="${EVOX_GAPPS_VENDOR_BOOT:?Set EVOX_GAPPS_VENDOR_BOOT to build 2447 vendor_boot.img}"
VANILLA_VENDOR_BOOT="${EVOX_VANILLA_VENDOR_BOOT:?Set EVOX_VANILLA_VENDOR_BOOT to build 2446 vendor_boot.img}"
PARTITION_SIZE=67108864
SALT_BOOT="7b22f88586dd801607b336180042313723583ec3dc519366971c80774d854bc3"
SALT_VENDOR_BOOT="4866259965667e0dee5521af4a6fcda03d8d58403a48ea50d8987854d835b896"

KERNEL_STEM="CMF-Phone-1-EvolutionX-11.10-FeaturePack-SecurityFix-v5-KSUNext-33252-SUSFS-2.2.0"
FOX_STEM="CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-v28-DualROM-TimeResourceFix"
PACK_TMP="$(mktemp -d "$ROOT/work/package-dual-rom-v5-v28.XXXXXX")"
trap 'rm -rf "$PACK_TMP"' EXIT

for required in "$MAGISKBOOT" "$AVBTOOL" "$AVB_KEY" "$KERNEL" "$KERNEL_CONFIG" \
  "$RECOVERY_RAMDISK" "$GAPPS_BOOT" "$VANILLA_BOOT" "$GAPPS_VENDOR_BOOT" "$VANILLA_VENDOR_BOOT"; do
  if [[ ! -f "$required" ]]; then
    echo "Missing required input: $required" >&2
    exit 1
  fi
done

if ! grep -qx 'CONFIG_BPF_UNPRIV_DEFAULT_OFF=y' "$KERNEL_CONFIG"; then
  echo "Security configuration is missing CONFIG_BPF_UNPRIV_DEFAULT_OFF=y" >&2
  exit 1
fi

if grep -qx 'CONFIG_BBG_BLOCK_RECOVERY=y' "$KERNEL_CONFIG"; then
  echo "Unsafe recovery-write blocking is enabled; refusing to package" >&2
  exit 1
fi

package_boot() {
  local variant="$1"
  local base="$2"
  local fingerprint="$3"
  local work="$PACK_TMP/boot-$variant"
  local output="$OUTPUTS/${KERNEL_STEM}-${variant}-boot.img"

  mkdir -p "$work/verify"
  (
    cd "$work"
    "$MAGISKBOOT" unpack "$base"
    cp "$KERNEL" kernel
    "$MAGISKBOOT" repack "$base" unsigned.img
  )
  cp "$work/unsigned.img" "$work/verify/boot.img"
  python3 "$AVBTOOL" erase_footer --image "$work/verify/boot.img"
  python3 "$AVBTOOL" add_hash_footer \
    --image "$work/verify/boot.img" \
    --partition_size "$PARTITION_SIZE" \
    --partition_name boot \
    --algorithm SHA256_RSA2048 \
    --key "$AVB_KEY" \
    --salt "$SALT_BOOT" \
    --prop com.android.build.boot.os_version:16 \
    --prop "com.android.build.boot.fingerprint:$fingerprint"
  python3 "$AVBTOOL" verify_image --image "$work/verify/boot.img"
  cp "$work/verify/boot.img" "$output"
}

package_vendor_boot() {
  local variant="$1"
  local base="$2"
  local fingerprint="$3"
  local work="$PACK_TMP/vendor-boot-$variant"
  local output="$OUTPUTS/${FOX_STEM}-${variant}-vendor_boot.img"

  mkdir -p "$work/verify"
  (
    cd "$work"
    # magiskboot returns a vendor-image status bit even after a successful
    # vendor_boot extraction, so validate the extracted fragment directly.
    "$MAGISKBOOT" unpack -n "$base" || unpack_status=$?
    if [[ ! -f vendor_ramdisk/recovery.cpio ]]; then
      echo "Failed to extract recovery ramdisk (magiskboot status ${unpack_status:-0})" >&2
      exit 1
    fi
    cp "$RECOVERY_RAMDISK" vendor_ramdisk/recovery.cpio
    "$MAGISKBOOT" repack "$base" unsigned.img
  )
  cp "$work/unsigned.img" "$work/verify/vendor_boot.img"
  python3 "$AVBTOOL" erase_footer --image "$work/verify/vendor_boot.img"
  python3 "$AVBTOOL" add_hash_footer \
    --image "$work/verify/vendor_boot.img" \
    --partition_size "$PARTITION_SIZE" \
    --partition_name vendor_boot \
    --algorithm SHA256_RSA2048 \
    --key "$AVB_KEY" \
    --salt "$SALT_VENDOR_BOOT" \
    --prop "com.android.build.vendor_boot.fingerprint:$fingerprint"
  python3 "$AVBTOOL" verify_image --image "$work/verify/vendor_boot.img"
  cp "$work/verify/vendor_boot.img" "$output"
}

GAPPS_FINGERPRINT="Nothing/lineage_Tetris/Tetris:16/BP4A.251205.006/2447:user/release-keys"
VANILLA_FINGERPRINT="Nothing/lineage_Tetris/Tetris:16/BP4A.251205.006/2446:user/release-keys"

package_boot GApps "$GAPPS_BOOT" "$GAPPS_FINGERPRINT"
package_boot Vanilla "$VANILLA_BOOT" "$VANILLA_FINGERPRINT"
package_vendor_boot GApps "$GAPPS_VENDOR_BOOT" "$GAPPS_FINGERPRINT"
package_vendor_boot Vanilla "$VANILLA_VENDOR_BOOT" "$VANILLA_FINGERPRINT"

cp "$KERNEL_CONFIG" "$OUTPUTS/${KERNEL_STEM}.config"
lz4 -l -12 -f "$KERNEL" "$OUTPUTS/${KERNEL_STEM}-Image.lz4"
cp "$GAPPS_VENDOR_BOOT" \
  "$OUTPUTS/CMF-Phone-1-EvolutionX-11.10-GApps-OFFICIAL-RESTORE-vendor_boot.img"
cp "$VANILLA_VENDOR_BOOT" \
  "$OUTPUTS/CMF-Phone-1-EvolutionX-11.10-Vanilla-OFFICIAL-RESTORE-vendor_boot.img"

(
  cd "$OUTPUTS"
  sha256sum \
    "${KERNEL_STEM}-GApps-boot.img" \
    "${KERNEL_STEM}-Vanilla-boot.img" \
    "${KERNEL_STEM}-Image.lz4" \
    "${KERNEL_STEM}.config" \
    "${FOX_STEM}-GApps-vendor_boot.img" \
    "${FOX_STEM}-Vanilla-vendor_boot.img" \
    CMF-Phone-1-EvolutionX-11.10-GApps-OFFICIAL-RESTORE-boot.img \
    CMF-Phone-1-EvolutionX-11.10-Vanilla-OFFICIAL-RESTORE-boot.img \
    CMF-Phone-1-EvolutionX-11.10-GApps-OFFICIAL-RESTORE-vendor_boot.img \
    CMF-Phone-1-EvolutionX-11.10-Vanilla-OFFICIAL-RESTORE-vendor_boot.img \
    > SHA256SUMS-CMF-Phone-1-DualROM-v5-v28
)

echo "Packaged and verified dual-ROM kernel v5 and OrangeFox v28 images in $OUTPUTS"
