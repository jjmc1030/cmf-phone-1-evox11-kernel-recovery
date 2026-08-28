#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
twrp_image="$script_dir/CMF-Phone-1-EvolutionX-11.10-TWRP-3.7.1_12-TouchFix-v4-vendor_boot.img"
restore_image="$script_dir/CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img"

usage() {
    printf 'Usage: %s install|restore\n' "$(basename "$0")"
    exit 2
}

[[ $# -eq 1 ]] || usage
case "$1" in
    install)
        action="INSTALL TWRP TOUCHFIX V4"
        image="$twrp_image"
        ;;
    restore)
        action="RESTORE STOCK RECOVERY"
        image="$restore_image"
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

device_count="$(fastboot devices | awk 'NF >= 1 { count++ } END { print count + 0 }')"
[[ "$device_count" -eq 1 ]] || {
    printf 'Expected exactly one phone in fastboot mode; found %s.\n' "$device_count" >&2
    exit 1
}

userspace="$(fastboot getvar is-userspace 2>&1 | sed -n 's/.*is-userspace: *//p' | tr -d '\r' | tail -n 1)"
[[ "$userspace" != "yes" ]] || {
    printf 'The phone is in fastbootd. Reboot to the bootloader and try again.\n' >&2
    exit 1
}

slot="$(fastboot getvar current-slot 2>&1 | sed -n 's/.*current-slot: *//p' | tr -d '\r' | tail -n 1)"
[[ "$slot" == "a" || "$slot" == "b" ]] || {
    printf 'Could not safely determine the current slot. Nothing was flashed.\n' >&2
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
fastboot reboot recovery
