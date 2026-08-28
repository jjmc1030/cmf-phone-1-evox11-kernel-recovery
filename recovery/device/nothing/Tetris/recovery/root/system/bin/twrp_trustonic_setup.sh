#!/system/bin/sh

# Make the Evolution X vendor Trustonic stack available to recovery. TWRP
# creates the logical vendor mapping from its own process, so this must poll in
# the background instead of blocking init before recovery can create it.

LOG=/tmp/twrp_trustonic_setup.log

log() {
    echo "twrp_trustonic_setup: $*" > /dev/kmsg 2>/dev/null
    echo "$(cut -d' ' -f1 /proc/uptime) $*" >> "$LOG"
}

start_service() {
    service_name=$1
    shift

    # Launch one recovery-owned instance; ctl.start caused competing restarts.
    : > "/tmp/${service_name}.log"
    setsid "$@" </dev/null >> "/tmp/${service_name}.log" 2>&1 &
    last_service_pid=$!
    sleep 0.5
    if ! kill -0 "$last_service_pid" 2>/dev/null; then
        log "$service_name direct start failed; see /tmp/${service_name}.log"
        return 1
    fi
    log "$service_name stable direct pid $last_service_pid"
    return 0
}

wait_property() {
    property_name=$1
    expected_value=$2
    limit=$3
    attempts=0

    while [ "$attempts" -lt "$limit" ]; do
        property_value=$(getprop "$property_name")
        if [ -n "$property_value" ] && { [ -z "$expected_value" ] || [ "$property_value" = "$expected_value" ]; }; then
            log "$property_name=$property_value after ${attempts}00ms"
            return 0
        fi
        sleep 0.1
        attempts=$((attempts + 1))
    done

    log "timeout waiting for $property_name (now '$(getprop "$property_name")')"
    return 1
}

: > "$LOG"
log "start pid $$"

slot_suffix=$(getprop ro.boot.slot_suffix)
vendor_device="/dev/block/mapper/vendor${slot_suffix}"
attempts=0
while [ ! -e "$vendor_device" ] && [ "$attempts" -lt 1200 ]; do
    sleep 0.1
    attempts=$((attempts + 1))
done

if [ ! -e "$vendor_device" ]; then
    for candidate in /dev/block/mapper/vendor_a /dev/block/mapper/vendor_b /dev/block/mapper/vendor; do
        if [ -e "$candidate" ]; then
            vendor_device=$candidate
            break
        fi
    done
fi

if [ ! -e "$vendor_device" ]; then
    log "fatal: no logical vendor device after ${attempts}00ms"
    exit 1
fi
log "using $vendor_device after ${attempts}00ms"

# Expose the canonical vendor binary path expected by Trustonic while retaining
# the recovery VINTF and modules outside it. Recovery temporarily mounts and
# unmounts /vendor while parsing the ROM fstab, so its lib64/app submounts are
# not stable during early startup.
mkdir -p /mnt/vendor_real
if ! mountpoint -q /mnt/vendor_real 2>/dev/null; then
    mount -t erofs -o ro "$vendor_device" /mnt/vendor_real
    log "mounted vendor payload rc=$?"
fi

mkdir -p /vendor/bin
if ! mount -o bind /mnt/vendor_real/bin /vendor/bin; then
    log "fatal: could not bind stock vendor bin directory"
    exit 1
fi
log "bound stock /vendor/bin"

# System Binder must precede the stock Trustonic libraries so Keystore2 can
# discover KeyMint on /dev/binder rather than /dev/vndbinder. Keep the vendor
# libraries under the stable payload mount instead of /vendor/lib64, which
# recovery removes while it probes the dynamic partitions.
export LD_LIBRARY_PATH="/system/lib64:/mnt/vendor_real/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
log "linker path pinned to system Binder plus stable ROM Trustonic libraries"

# Trustonic updates its persistent registry while it establishes the secure
# partition used to unwrap metadata encryption.  Android mounts this ext4
# filesystem read-write; a read-only mount leaves partition 0 unavailable.
mkdir -p /mnt/vendor/persist
if ! mountpoint -q /mnt/vendor/persist 2>/dev/null; then
    mount -t ext4 /dev/block/by-name/persist /mnt/vendor/persist
    log "mounted persist read-write rc=$?"
fi

mkdir -p /mnt/vendor/persist/mcRegistry
chown system:system /mnt/vendor/persist /mnt/vendor/persist/mcRegistry 2>/dev/null
chmod 0771 /mnt/vendor/persist /mnt/vendor/persist/mcRegistry 2>/dev/null
log "mcRegistry available: $(ls -ld /mnt/vendor/persist/mcRegistry 2>/dev/null)"

# Bootstrap Trustonic partition 0 before metadata-encrypted userdata mounts.
mkdir -p /data/vendor/mcRegistry
chown system:system /data/vendor/mcRegistry 2>/dev/null
chmod 0775 /data/vendor/mcRegistry 2>/dev/null
log "prepared temporary Trustonic partition 0"

if [ -e /dev/mobicore ]; then
    chown system:system /dev/mobicore 2>/dev/null
    chmod 0600 /dev/mobicore 2>/dev/null
fi
if [ -e /dev/teeperf ]; then
    chown system:system /dev/teeperf 2>/dev/null
    chmod 0660 /dev/teeperf 2>/dev/null
fi

# Recovery repeatedly mounts and unmounts /vendor while probing the ROM fstab.
# Execute the security daemons from the dedicated, stable EROFS mount instead
# of the transient /vendor/bin bind mount so startup cannot lose the binary.
if ! start_service mobicore /mnt/vendor_real/bin/mcDriverDaemon \
    --P1 /mnt/vendor/persist/mcRegistry \
    -r /mnt/vendor_real/app/mcRegistry/06090000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/020f0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/05120000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/05120000000000000000000000000001.drbin \
    -r /mnt/vendor_real/app/mcRegistry/05160000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/020b0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/05070000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/030b0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/03100000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/030c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/031c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/032c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/033c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/034c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/035c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/036c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/037c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/40188311faf343488db888ad39496f9a.drbin \
    -r /mnt/vendor_real/app/mcRegistry/070c0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/090b0000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/0f5eed3c3b5a47afacca69a84bf0efad.drbin \
    -r /mnt/vendor_real/app/mcRegistry/07060000000000000000000000007169.drbin \
    -r /mnt/vendor_real/app/mcRegistry/4be4f7dc1f2c11e5b5f7727283247c7f.drbin \
    -r /mnt/vendor_real/app/mcRegistry/08070000000000000000000000008270.drbin \
    -r /mnt/vendor_real/app/mcRegistry/07070000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/07407000000000000000000000000000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/9073f03a9618383bb1856eb3f990babd.drbin \
    -r /mnt/vendor_real/app/mcRegistry/6b3f5fa0f8cf55a7be2582587d62d63a.drbin \
    -r /mnt/vendor_real/app/mcRegistry/5020170115e016302017012521300000.drbin \
    -r /mnt/vendor_real/app/mcRegistry/07210000000000000000000000000000.drbin; then
    log "fatal: mobicore direct service failed"
    exit 1
fi
mobicore_pid=$last_service_pid

if ! wait_property ro.vendor.trustonic.ready true 300; then
    log "fatal: Trustonic daemon did not become ready"
    exit 1
fi

# Recovery unmounts /vendor while it probes the ROM fstab.  Wait until that
# cycle reaches the data-media setup point, then restore the canonical binary
# path expected by the proprietary Trustonic HALs.  The recovery process waits
# up to 15 seconds for recovery.trustonic.ready, so keep this wait bounded.
attempts=0
while ! grep -q "Settings storage is" /tmp/recovery.log 2>/dev/null && [ "$attempts" -lt 100 ]; do
    sleep 0.1
    attempts=$((attempts + 1))
done
if ! grep -q "Settings storage is" /tmp/recovery.log 2>/dev/null; then
    log "fatal: recovery vendor-unmount cycle did not finish"
    exit 1
fi

mkdir -p /vendor/bin
if ! mountpoint -q /vendor/bin 2>/dev/null; then
    if ! mount -o bind /mnt/vendor_real/bin /vendor/bin; then
        log "fatal: could not restore canonical vendor bin directory"
        exit 1
    fi
fi
log "canonical /vendor/bin restored after recovery mount cycle"

# The proprietary KeyMint and Gatekeeper clients open their trusted
# applications through relative vendor/app/mcRegistry paths.  Recovery does
# not keep the ROM's /vendor/app mounted after its fstab probe, so expose that
# payload alongside /vendor/bin before launching either HAL.
mkdir -p /vendor/app
if ! mountpoint -q /vendor/app 2>/dev/null; then
    if ! mount -o bind /mnt/vendor_real/app /vendor/app; then
        log "fatal: could not restore canonical vendor app directory"
        exit 1
    fi
fi
if [ ! -f /vendor/app/mcRegistry/0706000000000000000000000000004d.tlbin ]; then
    log "fatal: KeyMint trusted application is missing from /vendor/app"
    exit 1
fi
log "canonical /vendor/app restored after recovery mount cycle"

# KeyMint and Gatekeeper connect to mcDriverDaemon directly.  Launch them from
# their canonical path while retaining the stable /mnt/vendor_real libraries.
if ! start_service vendor.keymint-trustonic /vendor/bin/hw/android.hardware.security.keymint@3.0-service.trustonic; then
    log "fatal: KeyMint direct service failed"
    exit 1
fi
keymint_pid=$last_service_pid
if ! start_service vendor.gatekeeper-default /vendor/bin/hw/android.hardware.gatekeeper-service.trustonic; then
    log "fatal: Gatekeeper direct service failed"
    exit 1
fi
gatekeeper_pid=$last_service_pid

# Require the whole stack to survive its initial Binder registration before
# allowing recovery to enter the metadata-decrypt call.
sleep 1
for service_pid in "$mobicore_pid" "$keymint_pid" "$gatekeeper_pid"; do
    if ! kill -0 "$service_pid" 2>/dev/null; then
        log "fatal: Trustonic process $service_pid exited during stabilization"
        exit 1
    fi
done

setprop recovery.trustonic.ready 1
log "complete: mobicore=$mobicore_pid keymint=$keymint_pid gatekeeper=$gatekeeper_pid"

# Stay alive so init preserves the child service cgroup.
while kill -0 "$mobicore_pid" 2>/dev/null &&
      kill -0 "$keymint_pid" 2>/dev/null &&
      kill -0 "$gatekeeper_pid" 2>/dev/null; do
    sleep 5
done
setprop recovery.trustonic.ready 0
log "fatal: a required Trustonic process exited after startup"
exit 1
