# CMF Phone 1 OrangeFox Android 16 Experimental v1

This is an unofficial, experimental OrangeFox R11.3 recovery image for the
CMF Phone 1 (`Tetris`) running the supplied Evolution X 11.10 Android 16 ROM.
It has been built and statically verified, but it has not yet been boot-tested
on the phone.

## What changed from working TWRP v4

- Replaced the Android 12.1 recovery userspace with an Android 16.1 OrangeFox
  userspace.
- Added native Android 16 `keystore2`, KeyMint v3/v4, Gatekeeper, SecureClock,
  and SharedSecret support.
- Added a background setup service for Evolution X's Trustonic TEE, KeyMint,
  and Gatekeeper HALs.
- Added a bounded metadata-encryption retry so logical `vendor` can appear
  before FBE decryption is attempted.
- Added CMF-specific ConfigFS/FunctionFS MTP rules. The recovery waits for both
  MTP and ADB endpoints before attaching the USB gadget.
- Retained the ROM-matched F2FS `/data` and `/metadata` encryption flags.

## Hardware preservation

The normal-boot platform ramdisk, all 215 stock hardware modules, DTB, and
bootconfig are byte-for-byte identical to the working Evolution X/TWRP v4
image. Only the recovery ramdisk fragment changed. This image does not modify
`boot`, `init_boot`, the GApps boot image, KernelSU, or the installed ROM.

## Important warning

OrangeFox's Android 16 branch is experimental. Do not format `/data` if it
appears encrypted or unavailable. Restore the supplied stock `vendor_boot`
image if recovery does not boot correctly.

Recovery is stored in `vendor_boot` on this phone. Never flash this file to
`boot`, `init_boot`, or a standalone `recovery` partition. Do not use it on a
different ROM or device.

## Install and restore

Reconnect the phone in bootloader fastboot mode, then run:

```sh
./flash-orangefox-or-restore.sh install
```

The helper checks that exactly one phone is connected, refuses fastbootd,
detects the active slot, and requires `FLASH-VENDOR-BOOT` confirmation before
writing anything.

To restore the exact supplied Evolution X recovery:

```sh
./flash-orangefox-or-restore.sh restore
```

## First boot test

1. Confirm OrangeFox reaches its main screen and touch works.
2. Allow up to two minutes for the background Trustonic/decryption setup.
3. Check whether internal storage shows its real contents and capacity.
4. Connect USB and check both ADB and MTP.
5. Do not perform wipes, formats, installations, or backups until these basic
   checks pass.

If decryption or MTP fails but ADB works, collect:

```sh
adb pull /tmp/recovery.log
adb pull /tmp/twrp_trustonic_setup.log
adb shell getprop recovery.trustonic.ready
adb shell getprop sys.usb.state
adb shell getprop sys.usb.ffs.mtp.ready
```

## Verification

- Image size: exactly 67,108,864 bytes (64 MiB).
- Recovery fragment: 30,480,909 bytes, LZ4 legacy.
- Header: Android vendor boot v4 with PLATFORM and RECOVERY fragments.
- AVB: SHA256_RSA2048 footer, signature, and partition hash verified.
- Stock platform ramdisk SHA-256:
  `87972876c52eee7ffdd9b70f60d1ec8065823a374742fa48fbc7ec033e213bdc`
- Stock DTB SHA-256:
  `c8b0ec24d4573c03706717d02520f1f7438d7764466a8918a54052039748da35`
- Stock bootconfig SHA-256:
  `dca836574abf9269802b032b8be5a32838705586a49d348d1c396c2f7bd56219`

## SHA-256

- OrangeFox v1:
  `96d5b032f31a17dacebe2245875010100dc865d905241e91a87dfb94fa276473`
- Stock restore:
  `592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779`
