#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
image="$script_dir/CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img"
expected_hash="592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779"
expected_size="67108864"
remote_image="/tmp/CMF-Phone-1-stock-vendor_boot.img"

command -v adb >/dev/null 2>&1 || {
    printf 'adb was not found. Install Android platform-tools first.\n' >&2
    exit 1
}
[[ -f "$image" ]] || {
    printf 'Restore image is missing: %s\n' "$image" >&2
    exit 1
}

printf '%s  %s\n' "$expected_hash" "$image" | sha256sum -c -

printf 'Waiting for the brief recovery ADB window...\n'
adb wait-for-device
mapfile -t devices < <(adb devices | awk 'NR > 1 && NF >= 2 { print $1 " " $2 }')
[[ "${#devices[@]}" -eq 1 ]] || {
    printf 'Expected exactly one ADB device; found %s. Nothing was written.\n' "${#devices[@]}" >&2
    exit 1
}
read -r serial state <<< "${devices[0]}"
[[ "$state" == "recovery" || "$state" == "device" ]] || {
    printf 'ADB device %s is in state %s, not recovery/device. Nothing was written.\n' "$serial" "$state" >&2
    exit 1
}

adb_cmd=(adb -s "$serial")

# OrangeFox currently reboots a few seconds after its splash. Stop only the
# recovery UI service as soon as ADB appears; adbd is a separate service and
# remains available for the guarded restore below.
if [[ "$state" == "recovery" ]]; then
    "${adb_cmd[@]}" shell setprop ctl.stop recovery
    recovery_state="$("${adb_cmd[@]}" shell getprop init.svc.recovery | tr -d '\r[:space:]')"
    [[ "$recovery_state" == "stopped" ]] || {
        printf 'Could not hold the recovery service (state=%s). Rerun the helper at the next ADB window.\n' \
            "$recovery_state" >&2
        exit 1
    }
    printf 'Caught ADB and stopped the crashing OrangeFox service; the phone should remain connected.\n'
fi

uid="$("${adb_cmd[@]}" shell id -u | tr -d '\r[:space:]')"
[[ "$uid" == "0" ]] || {
    printf 'Recovery ADB is not running as root (uid=%s). Nothing was written.\n' "$uid" >&2
    exit 1
}

slot_suffix="$("${adb_cmd[@]}" shell getprop ro.boot.slot_suffix | tr -d '\r[:space:]')"
case "$slot_suffix" in
    _a|_b) ;;
    *)
        printf 'Could not safely determine the active slot (got %s). Nothing was written.\n' "$slot_suffix" >&2
        exit 1
        ;;
esac

target="/dev/block/by-name/vendor_boot${slot_suffix}"
resolved="$("${adb_cmd[@]}" shell readlink -f "$target" | tr -d '\r[:space:]')"
[[ "$resolved" == /dev/block/* ]] || {
    printf 'Could not resolve %s to a block device. Nothing was written.\n' "$target" >&2
    exit 1
}

partition_size="$("${adb_cmd[@]}" shell blockdev --getsize64 "$target" | tr -d '\r[:space:]')"
[[ "$partition_size" == "$expected_size" ]] || {
    printf 'Unexpected partition size %s for %s; expected %s. Nothing was written.\n' \
        "$partition_size" "$target" "$expected_size" >&2
    exit 1
}

"${adb_cmd[@]}" push "$image" "$remote_image"
remote_hash="$("${adb_cmd[@]}" shell sha256sum "$remote_image" | awk '{print $1}' | tr -d '\r')"
[[ "$remote_hash" == "$expected_hash" ]] || {
    printf 'The image checksum changed during ADB transfer. Nothing was written.\n' >&2
    exit 1
}

printf '\nDevice: %s\nADB state: %s\nActive slot: %s\nTarget: %s -> %s\nSize: %s bytes\nImage: %s\n\n' \
    "$serial" "$state" "${slot_suffix#_}" "$target" "$resolved" "$partition_size" "$(basename "$image")"
printf 'Type RESTORE-STOCK-VENDOR-BOOT to continue: '
read -r confirmation
[[ "$confirmation" == "RESTORE-STOCK-VENDOR-BOOT" ]] || {
    printf 'Cancelled. Nothing was written.\n'
    exit 1
}

"${adb_cmd[@]}" shell dd if="$remote_image" of="$target" bs=4194304 conv=fsync
"${adb_cmd[@]}" shell sync

readback_hash="$("${adb_cmd[@]}" shell "dd if='$target' bs=4194304 count=16 2>/dev/null | sha256sum" | awk '{print $1}' | tr -d '\r')"
[[ "$readback_hash" == "$expected_hash" ]] || {
    printf 'Read-back verification failed: %s\nDo not reboot; restore was not verified.\n' "$readback_hash" >&2
    exit 1
}

"${adb_cmd[@]}" shell rm -f "$remote_image"
printf 'Stock vendor_boot restored and verified on slot %s. Rebooting normally.\n' "${slot_suffix#_}"
"${adb_cmd[@]}" reboot
