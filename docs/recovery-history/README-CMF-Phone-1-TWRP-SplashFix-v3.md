# CMF Phone 1 TWRP SplashFix v3

This is an unofficial TWRP 3.7.1_12 test build for the CMF Phone 1 (Tetris)
running the supplied Evolution X 11.10 Android 16 build.

## Physical test result

Partially verified on the target phone on 2026-08-24. TWRP loaded the complete
main interface on slot B, ADB remained available, the stale recovery boot
command was cleared, and TWRP's own system-reboot command returned successfully
to a fully booted Android system. Wi-Fi was enabled after the reboot. Touch was
not functional, so the on-screen buttons and swipe control could not be used.
Use TouchFix v4 for the next recovery test.

## What v3 fixes

Physical testing of v2 proved that the kernel, display, ADB, and boot-control
cleanup start successfully. Recovery then blocked inside TWRP
12.1's automatic Android metadata-decryption path before loading the main UI.

V3 keeps the complete recovery crypto toolchain but skips that automatic call.
This is intended to let the main interface load and keep ADB sideload,
fastbootd, image flashing, and reboot controls usable. It also retains the v2
protection that clears stale recovery boot commands during startup and before a
system reboot.

## Important limitation

Internal storage and `/data` decryption did not work in the physical test. Do
not format data because it appears encrypted or unavailable. Use ADB sideload,
USB OTG, fastbootd, or direct image flashing instead.

Recovery is stored in `vendor_boot` on this phone. Never flash this image to
`boot`, `init_boot`, or a standalone `recovery` partition. Do not use it on a
different ROM or device.

## Verification

- Recovery fragment: 29,473,768 bytes, safely below 32 MiB.
- All 412 ELF executables and libraries have their required dependencies.
- AVB footer and SHA256_RSA2048 signature verified.
- The Evolution X platform ramdisk, DTB, and bootconfig compare byte-for-byte
  with the supplied working image.
- Final partition size is exactly 64 MiB.

## Install and restore

From bootloader fastboot mode, run:

```sh
./flash-twrp-or-restore.sh install
```

The helper targets only the detected active slot and requires the confirmation
`FLASH-VENDOR-BOOT`.

To restore the exact supplied Evolution X recovery:

```sh
./flash-twrp-or-restore.sh restore
```

## SHA-256

- SplashFix v3: `e0010d12214b51942b47db570a9996e67a2f3ffe2d2edd711c1c99151cb98e2c`
- Stock restore: `592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779`
