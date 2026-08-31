#!/usr/bin/env bash
set -euo pipefail

ROOT="${CMF_BUILD_ROOT:?Set CMF_BUILD_ROOT to the project build workspace}"
ROM="${NOTHINGOS41_ROM_DIR:?Set NOTHINGOS41_ROM_DIR to the extracted Nothing OS 4.1 package}"
OUT="${CMF_ORANGEFOX_OUT:-$ROOT/outputs/NothingOS-4.1-B4.1-260812-1726/recovery}"
WORK="${CMF_ORANGEFOX_WORK:-$ROOT/work/nothingos41/orangefox-v3-package}"
MAGISKBOOT="$ROOT/work/bootimg-tools/magiskboot"
AVBTOOL="$ROOT/work/bootimg-tools/avb/avbtool.py"
RECOVERY_RAMDISK="$ROOT/work/twrp/orangefox16-source/out/target/product/Tetris/obj/PACKAGING/vendor_ramdisk_fragments_intermediates/recovery.cpio.lz4"
NOS41_MANIFEST="$ROOT/work/twrp/orangefox16-source/device/nothing/Tetris/nothingos41/vendor-manifest.xml"

PARTITION_SIZE=67108864
EXPECTED_STOCK_SHA256="c4e449688c7e7218f8cb97253290540ae7645bad089da3dfd06cbc1c72b74bdd"
VENDOR_BOOT_SALT="5ca2dad88a3599579218ba07930cc6024960bbd2a36f09db9ce5518b0238bd46"
VENDOR_BOOT_FINGERPRINT="alps/hal_mgvi_64_64only_ww_armv82/mgvi_64_64only_ww_armv82:14/UP1A.231005.007/2608121726:user/release-keys"

IMAGE_NAME="${CMF_ORANGEFOX_IMAGE_NAME:-CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-OrangeFox-R12.0-v3-MinimalPlatform-EarlyADB-vendor_boot.img}"
RESTORE_NAME="CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-OFFICIAL-RESTORE-vendor_boot.img"

for required in "$ROM/vendor_boot.img" "$MAGISKBOOT" "$AVBTOOL" \
  "$RECOVERY_RAMDISK" "$NOS41_MANIFEST"; do
  test -f "$required" || { echo "Missing input: $required" >&2; exit 1; }
done

actual_stock_sha256=$(sha256sum "$ROM/vendor_boot.img" | awk '{print $1}')
if [[ "$actual_stock_sha256" != "$EXPECTED_STOCK_SHA256" ]]; then
  echo "The supplied stock vendor_boot does not match Nothing OS 4.1 B4.1-260812-1726." >&2
  echo "Expected: $EXPECTED_STOCK_SHA256" >&2
  echo "Actual:   $actual_stock_sha256" >&2
  exit 1
fi

mkdir -p "$OUT" "$WORK"
TMPDIR_BUILD=$(mktemp -d "$WORK/build.XXXXXX")
trap 'rm -rf "$TMPDIR_BUILD"' EXIT

# Use the freshly built OrangeFox recovery fragment, then install the exact
# Nothing OS device manifest in both locations understood by recovery tools.
cp "$RECOVERY_RAMDISK" "$TMPDIR_BUILD/recovery.cpio.lz4"
"$MAGISKBOOT" decompress "$TMPDIR_BUILD/recovery.cpio.lz4" "$TMPDIR_BUILD/recovery.cpio"
"$MAGISKBOOT" cpio "$TMPDIR_BUILD/recovery.cpio" \
  "add 0644 vendor/etc/vintf/manifest.xml $NOS41_MANIFEST" \
  "add 0644 vendor/manifest.xml $NOS41_MANIFEST"

VENDOR_WORK="$TMPDIR_BUILD/vendor-boot"
mkdir -p "$VENDOR_WORK"
(
  cd "$VENDOR_WORK"
  unpack_status=0
  "$MAGISKBOOT" unpack "$ROM/vendor_boot.img" || unpack_status=$?
  if [[ "$unpack_status" -ne 0 && "$unpack_status" -ne 3 ]]; then
    echo "Could not unpack the stock vendor_boot (status $unpack_status)" >&2
    exit 1
  fi
  test -f vendor_ramdisk/ramdisk.cpio
  test -f vendor_ramdisk/recovery.cpio

  # Header-v4 recovery boot concatenates the selected vendor ramdisk
  # fragments.  Nothing OS ships a complete stock recovery root in its
  # always-loaded platform fragment, unlike the minimal platform fragment in
  # the known-working Evolution X image.  Keeping that duplicate root makes
  # init, sepolicy, VINTF, services, libraries, resources, and system_ext
  # collide with OrangeFox.  Preserve only the platform data that belongs in
  # this fragment: first-stage mount files and the ROM-matched kernel modules.
  platform_directories=(
    acct apex config data data_mirror debug_ramdisk dev linkerconfig mnt odm
    odm_dlkm oem postinstall proc product res sdcard second_stage_resources
    storage sys system system_dlkm tmp vendor vendor_dlkm
  )
  platform_leaves=(
    bin bugreports d default.prop etc init
    odm_file_contexts odm_property_contexts
    plat_file_contexts plat_property_contexts plat_service_contexts
    product_file_contexts product_property_contexts product_service_contexts
    prop.default sepolicy system_ext
    system_ext_file_contexts system_ext_property_contexts system_ext_service_contexts
    vendor_file_contexts vendor_property_contexts vendor_service_contexts
  )

  cpio_commands=()
  for entry in "${platform_directories[@]}"; do
    cpio_commands+=("rm -r $entry")
  done
  for entry in "${platform_leaves[@]}"; do
    cpio_commands+=("rm $entry")
  done
  "$MAGISKBOOT" cpio vendor_ramdisk/ramdisk.cpio "${cpio_commands[@]}"

  "$MAGISKBOOT" cpio vendor_ramdisk/ramdisk.cpio "exists first_stage_ramdisk/fstab.mt6878"
  "$MAGISKBOOT" cpio vendor_ramdisk/ramdisk.cpio "exists first_stage_ramdisk/system/bin/snapuserd"
  "$MAGISKBOOT" cpio vendor_ramdisk/ramdisk.cpio "exists lib/modules/modules.load"

  cp "$TMPDIR_BUILD/recovery.cpio" vendor_ramdisk/recovery.cpio
  "$MAGISKBOOT" repack "$ROM/vendor_boot.img" unsigned.img
)

cp "$VENDOR_WORK/unsigned.img" "$TMPDIR_BUILD/vendor_boot.img"
python3 "$AVBTOOL" erase_footer --image "$TMPDIR_BUILD/vendor_boot.img"
python3 "$AVBTOOL" add_hash_footer \
  --image "$TMPDIR_BUILD/vendor_boot.img" \
  --partition_size "$PARTITION_SIZE" \
  --partition_name vendor_boot \
  --algorithm NONE \
  --salt "$VENDOR_BOOT_SALT" \
  --prop "com.android.build.vendor_boot.fingerprint:$VENDOR_BOOT_FINGERPRINT"
python3 "$AVBTOOL" verify_image --image "$TMPDIR_BUILD/vendor_boot.img"

test "$(stat -c %s "$TMPDIR_BUILD/vendor_boot.img")" -eq "$PARTITION_SIZE"
cp "$TMPDIR_BUILD/vendor_boot.img" "$OUT/$IMAGE_NAME"
cp "$ROM/vendor_boot.img" "$OUT/$RESTORE_NAME"

printf 'Packaged: %s\n' "$OUT/$IMAGE_NAME"
