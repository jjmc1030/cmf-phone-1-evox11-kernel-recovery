#!/usr/bin/env bash
set -euo pipefail

ROOT="${CMF_BUILD_ROOT:?Set CMF_BUILD_ROOT to the project build workspace}"
ROM="${NOTHINGOS41_ROM_DIR:?Set NOTHINGOS41_ROM_DIR to the extracted Nothing OS 4.1 package}"
OUT="${CMF_ORANGEFOX_OUT:-$ROOT/outputs/NothingOS-4.1-B4.1-260812-1726/recovery}"
SOURCE="$ROOT/work/twrp/orangefox16-source"
IMAGE="${CMF_ORANGEFOX_IMAGE:-$OUT/CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-OrangeFox-R12.0-v3-MinimalPlatform-EarlyADB-vendor_boot.img}"
RESTORE="$OUT/CMF-Phone-1-NothingOS-4.1-B4.1-260812-1726-OFFICIAL-RESTORE-vendor_boot.img"
STOCK="$ROM/vendor_boot.img"
BUILT_RECOVERY_LZ4="$SOURCE/out/target/product/Tetris/obj/PACKAGING/vendor_ramdisk_fragments_intermediates/recovery.cpio.lz4"
MAGISKBOOT="$ROOT/work/bootimg-tools/magiskboot"
AVBTOOL="$ROOT/work/bootimg-tools/avb/avbtool.py"
ASSEMBLE_VINTF="$SOURCE/out/host/linux-x86/bin/assemble_vintf"
UPX="$SOURCE/vendor/recovery/tools/upx"
NOS41_MANIFEST="$SOURCE/device/nothing/Tetris/nothingos41/vendor-manifest.xml"
SOURCE_FSTAB="$SOURCE/device/nothing/Tetris/recovery/root/recovery.fstab"
SOURCE_DEVICE_RC="$SOURCE/device/nothing/Tetris/recovery/root/init.recovery.mt6878.rc"
SOURCE_MODULES_LOAD_RECOVERY="$SOURCE/device/nothing/Tetris-kernel/vendor_boot/modules.load.recovery"

PARTITION_SIZE=67108864
EXPECTED_STOCK_SHA256="c4e449688c7e7218f8cb97253290540ae7645bad089da3dfd06cbc1c72b74bdd"
pass_count=0

pass() {
    printf 'PASS  %s\n' "$1"
    pass_count=$((pass_count + 1))
}

fail() {
    printf 'FAIL  %s\n' "$1" >&2
    exit 1
}

require_file() {
    test -f "$1" || fail "missing required file: $1"
}

unpack_vendor_boot() {
    local image=$1
    local destination=$2
    local status=0

    mkdir -p "$destination"
    (
        cd "$destination"
        "$MAGISKBOOT" unpack "$image" >unpack.log 2>&1 || status=$?
        test "$status" -eq 0 -o "$status" -eq 3
    ) || fail "could not unpack $image"
}

extract_cpio() {
    local archive=$1
    local destination=$2

    mkdir -p "$destination"
    (
        cd "$destination"
        "$MAGISKBOOT" cpio "$archive" extract >/dev/null 2>&1
    ) || fail "could not extract $archive"
}

write_tree_manifest() {
    local root=$1
    local output=$2

    (
        cd "$root"
        {
            find -P . -printf 'META  %y %m %U %G %P -> %l\n'
            find -P . -type f -print0 | LC_ALL=C sort -z | xargs -0 -r sha256sum
        } | LC_ALL=C sort
    ) >"$output"
}

for required in "$IMAGE" "$RESTORE" "$STOCK" "$BUILT_RECOVERY_LZ4" \
    "$MAGISKBOOT" "$AVBTOOL" "$ASSEMBLE_VINTF" "$UPX" \
    "$NOS41_MANIFEST" "$SOURCE_FSTAB" "$SOURCE_DEVICE_RC" "$SOURCE_MODULES_LOAD_RECOVERY"; do
    require_file "$required"
done

VALIDATE_TMP=$(mktemp -d /tmp/cmf-nothingos41-orangefox-v3-validate.XXXXXX)
trap 'rm -rf "$VALIDATE_TMP"' EXIT

test "$(stat -c %s "$IMAGE")" -eq "$PARTITION_SIZE" || fail "vendor_boot is not exactly 64 MiB"
pass "vendor_boot partition size"

test "$(sha256sum "$STOCK" | awk '{print $1}')" = "$EXPECTED_STOCK_SHA256" || fail "stock source image checksum"
test "$(sha256sum "$RESTORE" | awk '{print $1}')" = "$EXPECTED_STOCK_SHA256" || fail "packaged restore image checksum"
pass "exact Nothing OS 4.1 stock source and restore image"

cp "$IMAGE" "$VALIDATE_TMP/vendor_boot.img"
python3 "$AVBTOOL" verify_image --image "$VALIDATE_TMP/vendor_boot.img" >/dev/null || fail "AVB verification"
python3 "$AVBTOOL" info_image --image "$IMAGE" >"$OUT/AVB-INFO.txt"
rg -q '^[[:space:]]*Algorithm:[[:space:]]+NONE$' "$OUT/AVB-INFO.txt" || fail "AVB algorithm is not NONE"
rg -q '^[[:space:]]*Partition Name:[[:space:]]+vendor_boot$' "$OUT/AVB-INFO.txt" || fail "AVB partition name"
pass "AVB footer, hash, and partition metadata"

unpack_vendor_boot "$STOCK" "$VALIDATE_TMP/stock"
unpack_vendor_boot "$IMAGE" "$VALIDATE_TMP/final"

rg -q 'HEADER_VER[[:space:]]+\[4\]' "$VALIDATE_TMP/final/unpack.log" || fail "vendor_boot header version"
test "$(rg -c 'VND_RAMDISK.*type=\[platform\]' "$VALIDATE_TMP/final/unpack.log")" -eq 1 || fail "platform fragment count"
test "$(rg -c 'VND_RAMDISK.*name=\[recovery\] type=\[recovery\]' "$VALIDATE_TMP/final/unpack.log")" -eq 1 || fail "recovery fragment count"
rg -q 'CMDLINE[[:space:]]+\[bootopt=64S3,32N2,64N2 log_buf_len=1M ignore_loglevel printk.devkmsg=on\]' "$VALIDATE_TMP/final/unpack.log" || fail "stock vendor command line"
pass "header-v4 fragment table and stock command line"

cmp -s "$VALIDATE_TMP/stock/dtb" "$VALIDATE_TMP/final/dtb" || fail "DTB differs from stock"
pass "stock DTB preserved byte-for-byte"

extract_cpio "$VALIDATE_TMP/stock/vendor_ramdisk/ramdisk.cpio" "$VALIDATE_TMP/stock-platform"
extract_cpio "$VALIDATE_TMP/final/vendor_ramdisk/ramdisk.cpio" "$VALIDATE_TMP/final-platform"
extract_cpio "$VALIDATE_TMP/final/vendor_ramdisk/recovery.cpio" "$VALIDATE_TMP/recovery"

mapfile -t final_platform_roots < <(
    find -P "$VALIDATE_TMP/final-platform" -mindepth 1 -maxdepth 1 -printf '%f\n' | LC_ALL=C sort
)
test "${#final_platform_roots[@]}" -eq 2 || fail "platform fragment has unexpected top-level entries: ${final_platform_roots[*]}"
test "${final_platform_roots[0]}" = first_stage_ramdisk || fail "platform fragment first root"
test "${final_platform_roots[1]}" = lib || fail "platform fragment second root"
pass "platform fragment contains only first-stage files and kernel modules"

for retained_root in first_stage_ramdisk lib; do
    write_tree_manifest "$VALIDATE_TMP/stock-platform/$retained_root" "$VALIDATE_TMP/stock-$retained_root.manifest"
    write_tree_manifest "$VALIDATE_TMP/final-platform/$retained_root" "$VALIDATE_TMP/final-$retained_root.manifest"
    cmp -s "$VALIDATE_TMP/stock-$retained_root.manifest" "$VALIDATE_TMP/final-$retained_root.manifest" || \
        fail "$retained_root changed from the exact stock platform fragment"
done
pass "Nothing OS first-stage tree and module tree preserved byte-for-byte"

for retained in \
    first_stage_ramdisk/fstab.mt6878 \
    first_stage_ramdisk/system/bin/snapuserd \
    lib/modules/modules.load \
    lib/modules/nothing_writeback_kmsg.ko \
    lib/modules/mediatek-drm.ko \
    lib/modules/mt6375-battery.ko; do
    require_file "$VALIDATE_TMP/final-platform/$retained"
done
pass "stock fstab, snapuserd, display, battery, and vendor modules retained"

cmp -s "$VALIDATE_TMP/stock-platform/lib/modules/modules.load.recovery" "$SOURCE_MODULES_LOAD_RECOVERY" || \
    fail "compiled recovery module list differs from Nothing OS stock"
pass "compiled recovery module list matches Nothing OS stock exactly"

for forbidden in init prop.default sepolicy system system_ext vendor res; do
    test ! -e "$VALIDATE_TMP/final-platform/$forbidden" || fail "duplicate stock recovery root remains: $forbidden"
done
pass "duplicate stock init, policy, services, libraries, VINTF, and UI payload removed"

cp "$BUILT_RECOVERY_LZ4" "$VALIDATE_TMP/source-recovery.cpio.lz4"
"$MAGISKBOOT" decompress "$VALIDATE_TMP/source-recovery.cpio.lz4" "$VALIDATE_TMP/source-recovery.cpio" >/dev/null
"$MAGISKBOOT" cpio "$VALIDATE_TMP/source-recovery.cpio" \
    "add 0644 vendor/etc/vintf/manifest.xml $NOS41_MANIFEST" \
    "add 0644 vendor/manifest.xml $NOS41_MANIFEST" >/dev/null
extract_cpio "$VALIDATE_TMP/source-recovery.cpio" "$VALIDATE_TMP/source-recovery"
write_tree_manifest "$VALIDATE_TMP/source-recovery" "$VALIDATE_TMP/source-recovery.manifest"
write_tree_manifest "$VALIDATE_TMP/recovery" "$VALIDATE_TMP/final-recovery.manifest"
cmp -s "$VALIDATE_TMP/source-recovery.manifest" "$VALIDATE_TMP/final-recovery.manifest" || \
    fail "packaged recovery fragment differs from the freshly built source fragment"
pass "freshly built OrangeFox recovery fragment preserved exactly"

cmp -s "$VALIDATE_TMP/recovery/vendor/etc/vintf/manifest.xml" "$NOS41_MANIFEST" || fail "canonical recovery device manifest"
cmp -s "$VALIDATE_TMP/recovery/vendor/manifest.xml" "$NOS41_MANIFEST" || fail "legacy recovery device manifest"
test ! -e "$VALIDATE_TMP/recovery/system/etc/vintf/manifest/android.hardware.health-service.example.xml" || \
    fail "AIDL Health manifest remains in the framework VINTF directory"
require_file "$VALIDATE_TMP/recovery/vendor/etc/vintf/manifest/android.hardware.health@2.1.xml"
"$ASSEMBLE_VINTF" \
    -i "$VALIDATE_TMP/recovery/vendor/etc/vintf/manifest.xml:$VALIDATE_TMP/recovery/vendor/etc/vintf/manifest/android.hardware.health@2.1.xml" \
    -o "$VALIDATE_TMP/assembled-device-manifest.xml" >/dev/null || fail "device VINTF validation"
"$ASSEMBLE_VINTF" \
    -i "$VALIDATE_TMP/recovery/system/etc/vintf/manifest.xml" \
    -o "$VALIDATE_TMP/assembled-framework-manifest.xml" >/dev/null || fail "framework VINTF validation"
xmllint --noout \
    "$VALIDATE_TMP/recovery/vendor/etc/vintf/manifest.xml" \
    "$VALIDATE_TMP/recovery/vendor/manifest.xml" \
    "$VALIDATE_TMP/recovery/system/etc/vintf/manifest.xml" \
    "$VALIDATE_TMP/recovery/vendor/etc/vintf/manifest/android.hardware.health@2.1.xml" || fail "VINTF XML parsing"
pass "AIDL/HIDL VINTF manifests parse in the correct namespaces"

for property_file in prop.default default.prop; do
    rg -Fq 'init.svc_debug.no_fatal.ueventd=true' "$VALIDATE_TMP/recovery/$property_file" || fail "$property_file ueventd safeguard"
    rg -Fq 'init.svc_debug.no_fatal.charger=true' "$VALIDATE_TMP/recovery/$property_file" || fail "$property_file charger safeguard"
    rg -Fq 'ro.debuggable=1' "$VALIDATE_TMP/recovery/$property_file" || fail "$property_file recovery debug property"
done
cmp -s "$VALIDATE_TMP/recovery/init.recovery.mt6878.rc" "$SOURCE_DEVICE_RC" || fail "device recovery init script"
rg -Fq 'setprop init.svc_debug.no_fatal.ueventd true' "$VALIDATE_TMP/recovery/init.recovery.mt6878.rc" || fail "early ueventd safeguard"
rg -Fq 'setprop service.adb.root 1' "$VALIDATE_TMP/recovery/init.recovery.mt6878.rc" || fail "early root ADB request"
pass "critical-service reboot suppression and early root ADB diagnostics"

cmp -s "$VALIDATE_TMP/recovery/recovery.fstab" "$SOURCE_FSTAB" || fail "root recovery fstab"
cmp -s "$VALIDATE_TMP/recovery/system/etc/recovery.fstab" "$SOURCE_FSTAB" || fail "system recovery fstab"
rg -Fq 'fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized' "$VALIDATE_TMP/recovery/recovery.fstab" || fail "FBE encryption flags"
rg -Fq 'keydirectory=/metadata/vold/metadata_encryption' "$VALIDATE_TMP/recovery/recovery.fstab" || fail "metadata key directory"
rg -Fq 'sysfs_path=/sys/devices/platform/soc/112b0000.ufshci' "$VALIDATE_TMP/recovery/recovery.fstab" || fail "F2FS sysfs path"
rg -Fq 'fscompress' "$VALIDATE_TMP/recovery/recovery.fstab" || fail "F2FS compression flag"
pass "Nothing OS FBE metadata encryption and F2FS userdata flags"

for required_recovery_file in \
    system/bin/keystore2 \
    system/bin/fsck.f2fs \
    system/bin/make_f2fs \
    system/bin/sload_f2fs \
    system/bin/twrp_trustonic_setup.sh \
    system/etc/init/twrp_trustonic.rc \
    system/etc/init/twrp_mtp.rc \
    system/bin/minadbd \
    system/bin/update_engine_sideload \
    system/bin/hw/android.hardware.boot-service.default_recovery \
    system/bin/hw/android.hardware.health-service.example_recovery \
    twres/resources/images.xml \
    twres/images/Default/About/maintainer.png; do
    require_file "$VALIDATE_TMP/recovery/$required_recovery_file"
done
pass "decryption, format-data, MTP, sideload, BootControl, Health, and UI resources"

rg -Fq '/vendor/app/mcRegistry/0706000000000000000000000000004d.tlbin' \
    "$VALIDATE_TMP/recovery/system/bin/twrp_trustonic_setup.sh" || fail "Trustonic KeyMint trusted application check"
rg -Fq 'sys.usb.ffs.mtp.ready=1' "$VALIDATE_TMP/recovery/system/etc/init/twrp_mtp.rc" || fail "MTP FunctionFS readiness rule"
rg -Fq 'functions/ffs.mtp' "$VALIDATE_TMP/recovery/system/etc/init/twrp_mtp.rc" || fail "MTP ConfigFS function"
pass "Trustonic decryption bootstrap and MTP ConfigFS sequencing"

cp "$VALIDATE_TMP/recovery/system/bin/recovery" "$VALIDATE_TMP/recovery.unpacked"
"$UPX" -d "$VALIDATE_TMP/recovery.unpacked" >/dev/null || fail "could not inspect packed recovery executable"
strings "$VALIDATE_TMP/recovery.unpacked" >"$VALIDATE_TMP/recovery.strings"
for compiled_marker in \
    'focaltech_tp.ko' \
    'touchpanel_event_notify.ko' \
    'Waiting for ADB package...' \
    'Stopping ADB sideload...' \
    'ADB sideload complete. MTP remains off; enable it from Mount if needed.' \
    'ROM sideload complete. Reboot recovery before enabling MTP or flashing more files.'; do
    rg -Fq "$compiled_marker" "$VALIDATE_TMP/recovery.strings" || fail "compiled recovery marker: $compiled_marker"
done
pass "touchscreen module set and non-blocking sideload lifecycle compiled"

if [[ "${CMF_ORANGEFOX_PROFILE:-}" = nothingos41 ]]; then
    for required_module in bootinfo.ko touchpanel_event_notify.ko focaltech_tp.ko; do
        rg -Fq "$required_module" "$VALIDATE_TMP/recovery.strings" || fail "Nothing OS runtime module: $required_module"
    done
    for forbidden_module in sc8541_charger.ko upm6720_charger.ko nu2115_charger.ko sgm41606S_charger.ko; do
        test -z "$(rg -F "$forbidden_module" "$VALIDATE_TMP/recovery.strings" || true)" || \
            fail "Evolution X-only module remains in Nothing OS profile: $forbidden_module"
    done
    pass "Nothing OS-specific runtime module profile"
fi

if [[ "${CMF_ORANGEFOX_PROFILE:-}" = nothingos41-touchfix ]]; then
    for required_module in \
        sc8541_charger.ko upm6720_charger.ko nu2115_charger.ko \
        sgm41606S_charger.ko bootinfo.ko touchpanel_event_notify.ko focaltech_tp.ko; do
        rg -Fq "$required_module" "$VALIDATE_TMP/recovery.strings" || fail "Nothing OS touch dependency: $required_module"
    done
    rg -Fq 'sc8541_charger.ko upm6720_charger.ko nu2115_charger.ko sgm41606S_charger.ko 8250_mtk.ko' \
        "$VALIDATE_TMP/recovery.strings" || fail "touch symbol providers are not the compiled module-list prefix"
    pass "live-proven Nothing OS touch providers compiled before bootinfo"
fi

image_sha256=$(sha256sum "$IMAGE" | awk '{print $1}')
restore_sha256=$(sha256sum "$RESTORE" | awk '{print $1}')
printf '%s  %s\n%s  %s\n' \
    "$image_sha256" "$(basename "$IMAGE")" \
    "$restore_sha256" "$(basename "$RESTORE")" >"$OUT/SHA256SUMS"

printf '\nValidated %d checks.\nImage SHA-256: %s\nRestore SHA-256: %s\n' \
    "$pass_count" "$image_sha256" "$restore_sha256"
