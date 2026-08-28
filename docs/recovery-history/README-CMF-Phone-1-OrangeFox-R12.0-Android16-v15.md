# OrangeFox R12.0 Android 16 stock-platform v15

Target: CMF Phone 1 (`Tetris` / A015) on the tested Evolution X 11.10 GApps
Android 16 firmware.

## Final construction

v15 combines the final OrangeFox recovery ramdisk with the byte-for-byte tested
Evolution X platform ramdisk, DTB and bootconfig. This reversed the unsafe v14
normal-boot platform change while retaining the working recovery userspace.

Verified component SHA-256 values:

- Evolution X platform ramdisk:
  `87972876c52eee7ffdd9b70f60d1ec8065823a374742fa48fbc7ec033e213bdc`
- OrangeFox recovery ramdisk:
  `57e0c9a75df1972655bc77fc16e214eb51fac436929bd7f793b1a51a0cb03297`
- DTB:
  `c8b0ec24d4573c03706717d02520f1f7438d7764466a8918a54052039748da35`
- bootconfig:
  `dca836574abf9269802b032b8be5a32838705586a49d348d1c396c2f7bd56219`

## Fixes represented by the final source

- OrangeFox R12 interface on the Android 16 recovery base;
- PID 1 excluded from UPX compression;
- corrected APEX loop-device allocation and lifecycle;
- MediaTek touch and Trustonic startup;
- direct stable `mcDriverDaemon`, KeyMint and Gatekeeper processes;
- read-write Trustonic persistent registry;
- correct file-based-encryption state before metadata decryption;
- `/data`, `/data/media/0` and `/sdcard` read-write mount/decryption;
- internal-storage MTP after decryption;
- `TWRP_INCLUDE_LOGCAT` and `TARGET_USES_LOGD` flags;
- AIDL Health declaration in the vendor VINTF location, with the unwanted
  framework-side recovery example removed;
- battery reporting from the CMF power-supply path;
- corrected recovery clock handling without RTC drift;
- recovery and log-compression child-process cleanup;
- early Keystore2 panics mirrored to the kernel log for diagnosis.

## Final on-device validation

- Android → recovery → Android cycle passed;
- recovery UI and ADB remained online;
- metadata and Android user 0 decryption succeeded;
- `/data`, `/data/media/0` and `/sdcard` were read-write;
- host MTP descriptor appeared and Internal Storage was added;
- recovery clock was within one second of Android;
- battery percentage matched the kernel power-supply value;
- Trustonic, KeyMint, Gatekeeper, Keystore2, Health, logd and recovery kept
  stable PIDs through the final soak;
- no VINTF, F2FS, dm-crypt, panic or fatal recovery error appeared;
- normal Android boot completed without a recovery loop.

Physical touch remains a tester-visible check after each flash.

## Compatibility warning

The complete v15 `vendor_boot` is Evolution X platform-specific. Do not flash
it directly over stock Nothing OS or a different custom ROM. Reuse the recovery
source/fragment only after merging it with that ROM's own platform ramdisk,
DTB, bootconfig and AVB metadata. See `COMPATIBILITY.md`.

## Checksum

```text
699149cffeff003af2083c9057b90f87a8e4d4c19e3dbc53d65f1a269ae6f5b9  CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-StockPlatform-v15-vendor_boot.img
```
