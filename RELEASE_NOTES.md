# v1.0.0 — tested Evolution X 11.10 kernel and OrangeFox v17

Final publication of the CMF Phone 1 Android 16 kernel and OrangeFox development
work completed through 2026-08-28.

## Kernel

- Updated KernelSU Next to exact code `33252` from commit
  `1ce76ef55805697fcfa56aa18fb8dacd06b0dafb`.
- Built the matching Manager and `ksud`; fixed the installed
  `/data/adb/ksud` version mismatch.
- Retained the Linux 6.1 SUSFS `faccessat()` ABI correction and fd-based
  `execveat(AT_EMPTY_PATH)` SU handoff. ADB and Termux `su` are working.
- Retained SUSFS 2.2.0, Baseband Guard, DroidSpaces prerequisites, BBRv3,
  WireGuard, IP Set, IPv6 NAT, TTL/HL, CONNMARK, CAKE, fq/fq_codel, CIFS,
  NTSync, BTF/eBPF, FUSE BPF and tmpfs ACL/xattr support.
- Preserved the Evolution X MediaTek Wi-Fi/module ABI configuration.

## OrangeFox

- Upgraded to OrangeFox R12.0 on the Android 16 recovery base.
- Fixed the splash/restart loop, APEX loop-device handling and zombie child
  processes.
- Corrected `TWRP_INCLUDE_LOGCAT` and `TARGET_USES_LOGD` build flags.
- Corrected the AIDL Health manifest placement: the device fragment is
  vendor-side and the unwanted recovery example manifest is removed from the
  framework VINTF directory.
- Stabilized the ROM-matched Trustonic, KeyMint and Gatekeeper stack.
- Fixed metadata/FBE decryption, `/data` and `/data/media/0` read-write mount,
  internal-storage MTP, battery reporting and recovery clock handling.
- v17 retains the tested Evolution X platform ramdisk, DTB and bootconfig and
  changes only the recovery fragment relative to that platform base.
- Fixed Virtual A/B pre-wipe handling so active vendor mappings do not block the
  Format Data path before `mkfs.f2fs` is reached.
- Added guarded shutdown of the recovery-only Trustonic/Keystore stack and
  teardown of the metadata-encryption `userdata` mapping before formatting.
  The recovery refuses the operation if these resources cannot be released.

## Final validation

- Kernel booted Android repeatedly on `6.1.134-android14-11 #4`.
- Kernel, Manager and daemon all report KernelSU Next 33252.
- Wi-Fi disable/enable/reconnect, mobile data, sleep/wake, 64 MiB F2FS I/O,
  64 MiB CPU checksum and packet-loss tests passed.
- BindHosts is actually mounted and redirects a known ad-domain lookup.
- Android → recovery → Android passed with no bootloop.
- Recovery decrypted and mounted internal storage; MTP exposed it to the host.
- Recovery clock was within one second of Android and battery reporting matched.
- Recovery security/health services retained stable PIDs through the final soak.
- No current panic, oops, call trace, VINTF failure, F2FS failure or dm-crypt
  fatal error was found in the final tested logs.
- The v17 Format Data implementation compiled and its safe preconditions were
  inspected, but the irreversible userdata format was deliberately not executed.

## Release assets

- `CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-SUExecFix-v4-KSUNext-33252-SUSFS-2.2.0-boot.img`
- `CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-StockPlatform-v17-DataFormatFix-vendor_boot.img`
- `KernelSU-Next-v3.3.0-33252-CMF-local-manager.apk`
- `CMF-Phone-1-MediaTek-WiFi-Init-Config-Fix-KernelSU-v2.zip`
- `SHA256SUMS`

Official ROM restore images, raw device logs, backups, signing private keys and
files explicitly marked confidential are intentionally not redistributed.

Read `COMPATIBILITY.md` before using either image with stock Nothing OS or a
different custom ROM. The final OrangeFox `vendor_boot` is not a universal image.
