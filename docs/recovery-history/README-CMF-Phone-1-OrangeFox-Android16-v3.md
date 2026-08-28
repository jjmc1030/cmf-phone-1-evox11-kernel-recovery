# OrangeFox Android 16 Experimental v3 — CMF Phone 1

Target: CMF Phone 1 (`Tetris`) running the supplied Evolution X 11.10
Android 16 ROM.

This is an experimental `vendor_boot` recovery image. It does not replace the
Android `boot` image or the KernelSU kernel. v3 has passed offline structural,
dependency, and AVB verification, but it still requires an on-device test.

## Why v2 rebooted

The live v2 logs show that OrangeFox's build process had UPX-compressed
`/system/bin/init`. PID 1 started, but Android init later re-executed itself in
the `vendor_init` SELinux domain. SELinux denied executable memory and that
subprocess repeatedly crashed with signal 11, creating the recovery reboot
loop. The OrangeFox UI was not the process initially causing the loop.

v2 also provided the legacy HIDL Health 2.1 service while the Android 16
recovery stack requested the AIDL `android.hardware.health.IHealth/default`
interface.

## v3 changes

- Excludes `init` and symlinks from OrangeFox's UPX compression step. The final
  `init` is an ordinary dynamic AArch64 Android 36 executable with no UPX
  marker.
- Adds Android 16's recovery-specific AIDL Health v4 service and manifest for
  `IHealth/default`.
- Retains the v2 APEX-loop sizing fix, ROM-matched Trustonic crypto startup,
  guarded metadata-decryption behavior, VINTF declarations, and single
  ROM-matched recovery fstab.
- Preserves the known-working v2/official Evolution X platform vendor ramdisk,
  DTB, bootconfig, AVB key, AVB salt, and vendor-boot fingerprint byte-for-byte
  where applicable.

The final image is 64 MiB. Its AVB footer and complete recovery ELF dependency
closure were verified after final packing: 28 executable roots, 105 reachable
objects, 690 dependency edges, zero missing libraries, and zero invalid
interpreters.

## Install or restore

Boot the phone into bootloader fastboot mode, not fastbootd. From this folder:

```bash
./flash-orangefox-or-restore.sh install
```

The script verifies the image checksum, requires exactly one connected phone,
detects the active slot, refuses fastbootd, and requires the phrase
`FLASH-VENDOR-BOOT` before writing anything.

To restore the official Evolution X recovery from bootloader fastboot:

```bash
./flash-orangefox-or-restore.sh restore
```

## Test order

1. Confirm OrangeFox remains on the main screen for at least two minutes.
2. Confirm touch works while USB is connected and disconnected.
3. Open Mount and test `/data` or Internal Storage.
4. Test MTP only after `/data` is mounted or decrypted.
5. Do not format `/data` while troubleshooting decryption.

If recovery still restarts and ADB appears even briefly, run the collector
before restoring stock:

```bash
./collect-orangefox-v3-logs.sh
```

It only reads logs and does not reboot or flash the phone.

## SHA-256

```text
8b674cde34636238ca2a0f1a5c0b93dc8d6246911b29b7275b02b35fc3689f19  CMF-Phone-1-EvolutionX-11.10-OrangeFox-R11.3-Android16-Experimental-v3-vendor_boot.img
592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779  CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img
```
