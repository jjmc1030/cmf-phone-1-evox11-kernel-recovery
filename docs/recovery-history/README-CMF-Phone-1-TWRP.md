# CMF Phone 1 (Tetris) TWRP for Evolution X 11.10

> **Superseded:** Do not flash the first-test image documented below or the v2
> build. Use `SplashFix-v3` and `README-CMF-Phone-1-TWRP-SplashFix-v3.md`.

This is an **unofficial, first-test TWRP 3.7.1_12 build** made specifically
from the Evolution X 11.10 Android 16 images supplied on 2026-08-24.

## Files

- `CMF-Phone-1-EvolutionX-11.10-TWRP-3.7.1_12-vendor_boot.img` — TWRP
- `CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img` — exact
  original Evolution X recovery image
- `flash-twrp-or-restore.sh` — guarded installer and restore helper
- `SHA256SUMS-TWRP` — file-integrity hashes

## Important

Recovery is stored in **vendor_boot**, not `init_boot` or a standalone
`recovery` partition on this phone. Do not flash this image to another
partition, ROM version, device, or slot by hand unless you know the boot-chain
layout is identical.

The image keeps the supplied ROM's platform ramdisk, 215 MediaTek drivers,
DTB, bootconfig, command line, AVB key, fingerprint, and 64 MiB partition size.
Only the header-v4 `recovery` ramdisk fragment is replaced with TWRP.

The build contains TWRP, ADB/minadbd, ADB sideload, fastbootd, F2FS tools,
metadata/FBE crypto support, dynamic-partition tools, and the exact Tetris
recovery fstab. Static image, signature, archive, and direct library-dependency
checks passed.

## First-test warning

This image has not yet booted on the physical phone. Android 16 `/data`
decryption is especially uncertain because this TWRP branch is based on
Android 12.1. If TWRP cannot decrypt `/data`, **do not format data**. ADB
sideload and fastbootd may still work. Keep the restore image on the computer.

## Install

1. Charge the phone and keep the USB cable connected.
2. Boot into bootloader fastboot mode. Do not run the helper from fastbootd.
3. Open a terminal in this folder.
4. Run `./flash-twrp-or-restore.sh install`.
5. Read the detected device and slot, then type the exact confirmation shown.

The helper flashes only `vendor_boot` on the currently active slot and then
boots directly into recovery.

## Restore stock recovery

Boot into bootloader fastboot mode and run:

`./flash-twrp-or-restore.sh restore`

If the helper cannot be used, first check `fastboot getvar current-slot`, then
replace `b` below with the reported slot:

`fastboot --slot=b flash vendor_boot CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img`

`fastboot reboot recovery`

## Checksums

- TWRP: `441b89d0911117e71ed25de6d00dd452d73afe710372fdf142a9f219caddafa9`
- Stock restore: `592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779`
