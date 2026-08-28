#!/system/bin/sh

MODDIR=${0%/*}
LOG_FILE="$MODDIR/status.log"
TARGET_CONFIG="/vendor/firmware/wifi.cfg"

if grep -q '^DbgLevel0 11 0x0f$' "$TARGET_CONFIG" &&
   grep -q '^DbgLevel1 1 0x0f$' "$TARGET_CONFIG"; then
    printf '%s\n' "ACTIVE: systemless wifi.cfg remained mounted at service start" >> "$LOG_FILE"
    exit 0
fi

printf '%s\n' "ERROR: wifi.cfg override was replaced before service start" >> "$LOG_FILE"
exit 1
