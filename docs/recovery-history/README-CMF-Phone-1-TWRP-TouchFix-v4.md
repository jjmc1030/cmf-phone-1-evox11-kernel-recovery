# CMF Phone 1 TWRP TouchFix v4

This is an unofficial TWRP 3.7.1_12 test build for the CMF Phone 1 (Tetris)
running the supplied Evolution X 11.10 Android 16 build.

## Physical test result

Verified on the target phone on 2026-08-24. V4 booted the full TWRP interface
on slot B, loaded all seven added modules, and exposed the FocalTech panel as
`/dev/input/event2` with its correct 1080 by 2400 coordinate range. Physical
taps and a continuous swipe produced input events, and TWRP responded by
opening the Restore page and returning to the main page. ADB remained
available throughout the test.

## Touch fix

Android exposes the panel as `fts_ts`, driven by `focaltech_tp`. The v3 recovery
log showed that first-stage init loaded 207 modules but did not load the
FocalTech driver. TWRP successfully mounted `vendor_dlkm`, but v3 requested only
the early vendor-boot module set.

V4 explicitly loads the complete ROM-matched touchscreen chain before the UI:

- `sc8541_charger.ko`
- `upm6720_charger.ko`
- `nu2115_charger.ko`
- `sgm41606S_charger.ko`
- `bootinfo.ko`
- `touchpanel_event_notify.ko`
- `focaltech_tp.ko`

The module files are loaded from the preserved stock platform ramdisk and the
phone's matching Evolution X `vendor_dlkm` partition. V4 also retains v3's
automatic-decryption bypass and stale recovery-command cleanup.

## Important limitations

Internal storage and `/data` decryption remain unavailable. Do not format data
because it appears encrypted or unavailable. Use ADB sideload, USB OTG,
fastbootd, or direct image flashing instead.

Recovery is stored in `vendor_boot` on this phone. Never flash this image to
`boot`, `init_boot`, or a standalone `recovery` partition. Do not use it on a
different ROM or device.

## Verification

- Recovery fragment: 29,473,623 bytes, safely below 32 MiB.
- All 412 ELF executables, libraries, and resolved links have their required
  dependencies.
- AVB footer and SHA256_RSA2048 signature verified.
- The Evolution X platform ramdisk, DTB, and bootconfig compare byte-for-byte
  with the supplied working image.
- Final partition size is exactly 64 MiB.
- Physical touchscreen input and TWRP page navigation verified on slot B.

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

- TouchFix v4: `8ea86e941fbe08522e753283dbcffc1e5df0deb362e9f678f99cfedcc5b483a1`
- Stock restore: `592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779`
