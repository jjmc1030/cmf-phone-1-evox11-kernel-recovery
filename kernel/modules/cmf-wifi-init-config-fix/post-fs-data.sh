#!/system/bin/sh

MODDIR=${0%/*}
LOG_FILE="$MODDIR/status.log"
SOURCE_CONFIG="$MODDIR/wifi.cfg"
TARGET_CONFIG="/vendor/firmware/wifi.cfg"

: > "$LOG_FILE"
printf '%s\n' "CMF Phone 1 Wi-Fi init configuration fix v1.1" >> "$LOG_FILE"

if [ ! -f "$SOURCE_CONFIG" ] || [ ! -f "$TARGET_CONFIG" ]; then
    printf '%s\n' "ERROR: source or target wifi.cfg is missing" >> "$LOG_FILE"
    exit 1
fi

chown 0:0 "$SOURCE_CONFIG"
chmod 0644 "$SOURCE_CONFIG"
chcon u:object_r:vendor_file:s0 "$SOURCE_CONFIG"

if ! mount -o bind "$SOURCE_CONFIG" "$TARGET_CONFIG"; then
    printf '%s\n' "ERROR: could not bind the systemless wifi.cfg override" >> "$LOG_FILE"
    exit 1
fi

if grep -q '^DbgLevel0 11 0x0f$' "$TARGET_CONFIG" &&
   grep -q '^DbgLevel1 1 0x0f$' "$TARGET_CONFIG"; then
    printf '%s\n' "MOUNTED: startup debug masks are ready before Android services" >> "$LOG_FILE"
    exit 0
fi

printf '%s\n' "ERROR: mounted wifi.cfg failed content verification" >> "$LOG_FILE"
exit 1
