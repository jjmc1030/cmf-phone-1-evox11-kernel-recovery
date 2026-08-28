# OrangeFox Android 16 Experimental v2 — CMF Phone 1

Target: CMF Phone 1 (`Tetris`) running the supplied Evolution X 11.10 Android 16 ROM.

This is an experimental `vendor_boot` recovery image. It does not replace the
Android `boot` image or the KernelSU kernel.

## Why v1 rebooted

The captured v1 logs show three faults in the recovery startup/decryption path:

1. OrangeFox/TWRP closed an APEX payload file before determining its size. The
   resulting `-1` loop-device size produced `Value too large for defined data
   type` while mounting the Android APEX files.
2. Recovery then reparsed an additional vendor fstab and stopped immediately
   after `Using additional fstab for decryption` while automatic metadata-FBE
   decryption was starting.
3. Recovery had Trustonic KeyMint and Gatekeeper declarations in the framework
   VINTF directory but no main device/framework manifests. `servicemanager`
   reported `NULL VINTF MANIFEST`, and the proprietary crypto services changed
   from `running` to `restarting`.

The kernel log does not show a kernel panic. Init repeatedly restarted the
recovery process, and the recovery boot target caused the visible splash loop.

## v2 changes

- Fixes APEX loop allocation and records the payload size while its descriptor
  is still valid.
- Uses the exact Evolution X Trustonic service users/groups (`system:system`)
  and stock `/dev/mobicore` and `/dev/teeperf` permissions.
- Adds valid Android 16 device/framework VINTF manifests for Gatekeeper,
  KeyMint, SecureClock, SharedSecret, Keystore2, and the existing health HAL.
- Uses only the ROM-matched recovery fstab instead of reparsing the additional
  vendor fstab.
- Requires mobicore, TEE, KeyMint, and Gatekeeper to remain running before
  metadata decryption starts.
- Fails safely: if the proprietary crypto stack is unavailable, OrangeFox
  skips automatic metadata decryption and opens the UI instead of entering a
  recovery restart loop. A later manual decrypt/mount action retries metadata
  decryption.

The final image preserves the official Evolution X platform vendor ramdisk,
DTB, bootconfig, AVB key, AVB salt, and vendor-boot fingerprint byte-for-byte
where applicable. AVB and the final partition hash were verified after packing.

## Install or restore

Boot the phone into bootloader fastboot mode, not fastbootd. From this folder:

```bash
./flash-orangefox-or-restore.sh install
```

The script checks that exactly one device is connected, verifies the image
checksum, detects the active slot, and requires the phrase
`FLASH-VENDOR-BOOT` before writing anything.

To restore the official Evolution X recovery from bootloader fastboot:

```bash
./flash-orangefox-or-restore.sh restore
```

## Test order

1. Confirm OrangeFox remains on the main screen for at least two minutes.
2. Confirm touch still works.
3. Open Mount and test `/data` or Internal Storage.
4. Test MTP only after `/data` is mounted/decrypted.
5. Do not format `/data` to troubleshoot decryption.

If recovery still fails but ADB remains available, collect these before
restoring stock:

```bash
adb pull /tmp/recovery.log orangefox-v2-recovery.log
adb pull /tmp/twrp_trustonic_setup.log orangefox-v2-trustonic.log
adb shell dmesg > orangefox-v2-dmesg.log
```

## SHA-256

```text
77850814c5e6e85b388ab72912b51913b6ce79dc29d0cbac5a0ede60fc82103d  CMF-Phone-1-EvolutionX-11.10-OrangeFox-R11.3-Android16-Experimental-v2-vendor_boot.img
592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779  CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img
```
