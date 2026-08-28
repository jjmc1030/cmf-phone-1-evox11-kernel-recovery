# OrangeFox R12.0 Android 16 Experimental v4 — CMF Phone 1

Target: CMF Phone 1 (`Tetris`) running Evolution X 11.10 / Android 16.

This is a 64 MiB `vendor_boot` recovery image. It does not replace Android's
`boot` image or the working KernelSU Next kernel.

## R12.0 upgrade

- Uses OrangeFox's official Android 16 `fox_16.0-R12` vendor base.
- Ports the official R12.0 interface overhaul to the Android 16 recovery
  backend: SVG rendering, new icons, Inter fonts, new themes, and gesture
  navigation.
- Retains the Android 16 WLAN page and resources while using the R12 layout.

Upstream references:

- <https://gitlab.com/OrangeFox/vendor/recovery/-/tree/fox_16.0-R12>
- <https://gitlab.com/OrangeFox/bootable/Recovery/-/tree/fox_12.1>

## Device fixes retained or added

- Keeps the v3 startup fix: PID 1 and init symlinks are never UPX-compressed.
- Keeps the CMF Phone 1 touch and Trustonic startup setup used by working v3.
- Enables ADB/MTP before data decryption by disabling OrangeFox advanced
  security for this experimental build.
- Publishes FBE (`ro.crypto.type=file`) before starting metadata decryption,
  waits for the Trustonic/KeyMint stack, and explicitly uses the ROM-matched
  `/etc/recovery.fstab`.
- Creates the temporary Trustonic partition-0 registry path and declares
  `vendor.trustonic.tee@1.1::ITee/default` in the recovery device manifest.
- Places the AIDL Health v4 declaration in the vendor device VINTF manifest.
  The invalid framework-side device manifest is no longer installed.

## Verification completed

- Clean Android 16 `vendorbootimage` build completed successfully.
- The connected phone's active `vendor_boot_b` checksum exactly matched the
  known-working v3 image before this package was created.
- The platform vendor ramdisk, DTB, and bootconfig are byte-identical to v3.
- The AVB footer and SHA256_RSA2048 signature verify successfully.
- `init` is a normal Android 36 AArch64 executable and has no UPX marker.
- R12.0 and the metadata-decryption diagnostics are embedded in recovery; the
  old `ADB & MTP disabled by maintainer` path is absent.
- Recovery ELF closure: 28 executable roots, 105 reachable objects, 690
  dependency edges, zero missing libraries, and zero invalid interpreters.

Internal-storage decryption and MTP still require an on-device recovery test.
Do not format `/data` while testing.

## Install or restore

Boot the phone into bootloader fastboot mode, not fastbootd. From this folder:

```bash
./flash-orangefox-or-restore.sh install
```

The script verifies the image checksum, requires exactly one connected phone,
detects the active slot, rejects fastbootd, and asks for the phrase
`FLASH-VENDOR-BOOT` before writing.

Restore the official Evolution X recovery with:

```bash
./flash-orangefox-or-restore.sh restore
```

## Test order

1. Confirm OrangeFox stays on the main screen for at least two minutes.
2. Confirm touch works with USB connected and disconnected.
3. Confirm ADB is available.
4. Test mounting `/data` and opening Internal Storage without formatting it.
5. Test MTP after the mount/decryption attempt.
6. If anything fails, run `./collect-orangefox-r12-v4-logs.sh` before rebooting.

## SHA-256

```text
3be12c501cc230adb146cd1dd758f6004774d1682661c0532629f0a9a18076ad  CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-Experimental-v4-vendor_boot.img
592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779  CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img
```
