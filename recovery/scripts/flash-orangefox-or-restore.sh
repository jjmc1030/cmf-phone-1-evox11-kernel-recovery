#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s install|restore\n' "$(basename "$0")"
    printf 'Install requires ORANGEFOX_IMAGE and ORANGEFOX_SHA256 for your exact ROM build.\n'
    printf 'Restore requires RESTORE_IMAGE and RESTORE_SHA256 from your exact ROM build.\n'
    exit 2
}

[[ $# -eq 1 ]] || usage
case "$1" in
    install)
        [[ -n "${ORANGEFOX_IMAGE:-}" && -n "${ORANGEFOX_SHA256:-}" ]] || usage
        action="INSTALL USER-SUPPLIED ROM-MATCHED ORANGEFOX VENDOR_BOOT"
        image="$ORANGEFOX_IMAGE"
        expected_sha256="$ORANGEFOX_SHA256"
        ;;
    restore)
        [[ -n "${RESTORE_IMAGE:-}" && -n "${RESTORE_SHA256:-}" ]] || usage
        action="RESTORE USER-SUPPLIED ROM-MATCHED VENDOR_BOOT"
        image="$RESTORE_IMAGE"
        expected_sha256="$RESTORE_SHA256"
        ;;
    *) usage ;;
esac

command -v fastboot >/dev/null 2>&1 || {
    printf 'fastboot was not found. Install Android platform-tools first.\n' >&2
    exit 1
}
[[ -f "$image" ]] || {
    printf 'Required image is missing: %s\n' "$image" >&2
    exit 1
}

actual_sha256="$(sha256sum "$image" | awk '{print $1}')"
[[ "$actual_sha256" == "$expected_sha256" ]] || {
    printf 'Image checksum does not match. Nothing was flashed.\n' >&2
    printf 'Expected: %s\nActual:   %s\n' "$expected_sha256" "$actual_sha256" >&2
    exit 1
}

device_count="$(fastboot devices | awk 'NF >= 1 { count++ } END { print count + 0 }')"
[[ "$device_count" -eq 1 ]] || {
    printf 'Expected exactly one phone in bootloader fastboot mode; found %s. Nothing was flashed.\n' "$device_count" >&2
    exit 1
}

userspace="$(fastboot getvar is-userspace 2>&1 | sed -n 's/.*is-userspace: *//p' | tr -d '\r' | tail -n 1)"
[[ "$userspace" != "yes" ]] || {
    printf 'The phone is in fastbootd. Reboot to the bootloader and try again. Nothing was flashed.\n' >&2
    exit 1
}

slot="$(fastboot getvar current-slot 2>&1 | sed -n 's/.*current-slot: *//p' | tr -d '\r' | tail -n 1)"
[[ "$slot" == "a" || "$slot" == "b" ]] || {
    printf 'Could not safely determine the active slot. Nothing was flashed.\n' >&2
    exit 1
}

serial="$(fastboot devices | awk 'NF >= 1 { print $1; exit }')"
printf '\nAction: %s\nDevice: %s\nActive slot: %s\nPartition: vendor_boot_%s\nImage: %s\n\n' \
    "$action" "$serial" "$slot" "$slot" "$(basename "$image")"
printf 'Type FLASH-VENDOR-BOOT to continue: '
read -r confirmation
[[ "$confirmation" == "FLASH-VENDOR-BOOT" ]] || {
    printf 'Cancelled. Nothing was flashed.\n'
    exit 1
}

fastboot --slot="$slot" flash vendor_boot "$image"
if [[ "$1" == "install" ]]; then
    fastboot reboot recovery
else
    fastboot reboot
fi
