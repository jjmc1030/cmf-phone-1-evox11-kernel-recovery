#!/usr/bin/env bash
set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
capture_stamp="$(date +%Y%m%d-%H%M%S)"
capture_dir="$script_dir/orangefox-v3-logs-$capture_stamp"

command -v adb >/dev/null 2>&1 || {
    printf 'adb was not found. Install Android platform-tools first.\n' >&2
    exit 1
}

device_count="$(adb devices | awk 'NR > 1 && $2 != "" { count++ } END { print count + 0 }')"
if [[ "$device_count" -ne 1 ]]; then
    printf 'Expected exactly one ADB device; found %s. Nothing was collected.\n' "$device_count" >&2
    exit 1
fi

mkdir -p "$capture_dir"

adb pull /tmp/recovery.log "$capture_dir/recovery.log" || true
adb pull /tmp/twrp_trustonic_setup.log "$capture_dir/twrp_trustonic_setup.log" || true
adb shell dmesg > "$capture_dir/dmesg.log" 2>&1 || true
adb logcat -b all -d > "$capture_dir/logcat-all.log" 2>&1 || true
adb shell 'for pstore_file in /sys/fs/pstore/*; do [ -f "$pstore_file" ] || continue; echo "FILE:$pstore_file"; cat "$pstore_file"; done' \
    > "$capture_dir/pstore.log" 2>&1 || true
adb shell 'getprop; echo; ps -AZ' > "$capture_dir/properties-and-processes.log" 2>&1 || true

printf 'Logs saved in: %s\n' "$capture_dir"
