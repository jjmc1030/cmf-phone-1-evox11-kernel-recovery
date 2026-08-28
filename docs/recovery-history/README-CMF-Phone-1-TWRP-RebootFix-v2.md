# CMF Phone 1 TWRP RebootFix v2

> **Superseded after physical testing:** v2 clears the recovery boot command,
> but hangs while automatically processing Android 16 metadata encryption and
> never reaches the main interface. Use the `SplashFix-v3` image instead.

This is an unofficial TWRP 3.7.1_12 test build for the CMF Phone 1 (Tetris)
running the supplied Evolution X 11.10 Android 16 build.

## Use these files

- `CMF-Phone-1-EvolutionX-11.10-TWRP-3.7.1_12-RebootFix-v2-vendor_boot.img`
- `CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img`
- `flash-twrp-or-restore.sh`
- `SHA256SUMS-TWRP-RebootFix-v2`

Do not use the older image named
`CMF-Phone-1-EvolutionX-11.10-TWRP-3.7.1_12-vendor_boot.img`.

## Changes in v2

- Clears the one-shot recovery command as soon as the misc partition becomes
  available.
- Clears it again before TWRP reboots to Android, preventing a stale boot
  command from returning the phone to recovery.
- Adds a direct `/dev/block/by-name/misc` fallback if TWRP's first boot-control
  lookup is not ready.
- Includes the missing `libsysutils.so` dependency used by the file-encryption
  tooling.
- Removes optional Python and extra-language payloads. The recovery fragment is
  29,491,061 bytes, leaving 4,063,371 bytes of headroom below 32 MiB.
- Preserves the supplied ROM's normal-boot platform ramdisk, DTB, bootconfig,
  command line, fingerprint, AVB parameters, and 64 MiB partition size.

The complete recovery filesystem was audited: all 412 ELF files have their
required shared libraries. The final image was unpacked again, all preserved
ROM components compared byte-for-byte, and its AVB signature verified.

## Test status and caution

This is a fix candidate, not yet confirmed on the physical phone. The previous
build reached TWRP but could not return reliably to Android. This v2 specifically
hardens that reboot path.

Android 16 `/data` decryption is still unverified because this TWRP branch is
based on Android 12.1. If TWRP cannot decrypt `/data`, do not format data. ADB
sideload and fastbootd may still be usable. Keep the stock restore image on the
computer throughout the test.

Recovery is in `vendor_boot` on this phone. Never flash this file to `boot`,
`init_boot`, or a standalone `recovery` partition, and do not use it on another
ROM or device.

## Install or restore

From bootloader fastboot mode (not fastbootd), run:

```sh
./flash-twrp-or-restore.sh install
```

The helper detects the active slot, shows the exact target, and requires the
confirmation `FLASH-VENDOR-BOOT` before writing anything.

To restore the exact supplied Evolution X recovery:

```sh
./flash-twrp-or-restore.sh restore
```

## SHA-256

- RebootFix v2: `9d0ebb03c63820da8e17a9505603c0dd6a594b8aa1cd746c4450783d0523624c`
- Stock restore: `592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779`
