# CMF Phone 1 (Tetris) — Nothing OS 4.1 FeaturePack kernel v2

## Exact target

- Device: CMF Phone 1 (`Tetris`, model `A015`)
- Nothing OS 4.1 / Android 16
- Build: `B4.1-260812-1726`
- Incremental: `2608121726`
- Stock kernel: `6.1.162-android14-11-g65896c4edca1-ab15242664`
- GKI source: `android14-6.1-2026-03_r9`, commit `65896c4edca1614fb2844dc27399c9347d28f86d`

Do not flash this image on Evolution X, another Nothing OS release, another device, or another kernel base. The bootloader must be unlocked.

## v2 connectivity fix

The rejected v1 image booted Android but prevented the official Nothing OS Bluetooth core module from exporting its GKI-protected HCI symbols. The custom build had generated a different module-signing certificate, so Android treated the stock signed `system_dlkm` module as untrusted. The MediaTek Bluetooth driver then failed with unresolved HCI symbols, and Wi-Fi initialization also failed as the connectivity module chain broke.

v2 embeds the public module-signing certificate extracted from the exact official Nothing OS 4.1 stock kernel in the kernel trusted keyring. The certificate serial is `5732B3035A6B7A9FD15D6A25033124F7672FF5AC`, which exactly matches the signer ID of the official `system_dlkm/bluetooth.ko`. No private signing key is included or required.

## Features

- KernelSU Next 33252 with SUSFS 2.2.0
- Baseband Guard, with boot/recovery write blocking disabled for recovery compatibility
- BBR v1 and BBR v3
- WireGuard
- IP Set, IPv6 NAT, TTL/HL targets and connmark
- CAKE, fq and fq_codel
- CUBIC, BIC, Westwood and HTCP
- CIFS
- tmpfs extended attributes and POSIX ACLs
- NTSync
- BTF/eBPF, BPF events and FUSE-BPF
- User, PID, IPC and network namespace prerequisites for DroidSpaces-style containers
- Unprivileged BPF disabled by default

## Offline validation

- Kernel release is exactly `6.1.162-android14-11`.
- Final boot image is exactly 64 MiB and passes AVB verification.
- Re-extracting the packaged boot image produces a kernel byte-for-byte identical to the successful build output.
- The embedded trusted certificate is byte-for-byte identical to the public certificate in the official stock kernel.
- Official system Bluetooth, vendor Bluetooth, cfg80211, mac80211, MediaTek Bluetooth and MediaTek Wi-Fi module requirements have zero symbol CRC mismatches against the v2 build.
- The image contains the requested KernelSU/SUSFS, networking, filesystem, NTSync, BPF and Baseband Guard configuration.

The kernel was built with AOSP Clang `r487747b` 17.0.1. The stock kernel reports `r487747c` 17.0.2; v1 already booted successfully with `r487747b`, and the complete module CRC comparison remains exact. Controlled live-device validation is documented below.

## Live-test status

Initial live-device validation passed on 2026-08-31 with the exact target build on slot A, while retaining stock `vendor_boot`:

- Android completed a normal boot with kernel release `6.1.162-android14-11` and no recovery loop.
- Official `bluetooth`, `cfg80211` and `mac80211` modules loaded successfully with `bt_drv_6878` and `wlan_drv_gen4m_6878`.
- `wlan0` was present and Android reported Wi-Fi enabled.
- Five Bluetooth enable/disable cycles completed successfully with no crash, HCI timeout or driver error; Bluetooth was returned to its original disabled setting.
- Wi-Fi completed 20 direct-IP pings and five DNS pings with 0% packet loss. It also resumed immediately after forced deep idle with another five successful pings.
- The phone, Telecom, subscription, radio and MediaTek IMS interfaces were present with no modem kernel error. Both SIM slots were empty, so carrier registration, mobile data, IMS registration and a real call could not be tested.
- Camera service reported four devices and two normal cameras. The Nothing Camera opened the rear sensor and saved a 1.84 MB JPEG without a camera or cameraserver crash.
- Location and the GNSS provider were enabled. MediaTek GNSS modules loaded, high-accuracy requests reached the GPS provider, and no GNSS driver error appeared. No satellite TTFF was recorded indoors, so an outdoor satellite fix remains unverified.
- KernelSU returned version code `33252`; root executed as `uid=0` in SELinux context `u:r:ksu:s0`.
- `/data/adb/ksud` reported the matching `3.3.0-38-g1ce76ef5` build, eliminating the earlier daemon mismatch.
- SUSFS activity appeared in current-boot KernelSU logs. `/dev/ntsync` and `/sys/kernel/btf/vmlinux` were present.
- A controlled 15-second suspend/resume retained Wi-Fi, Bluetooth, phone and KernelSU services. A five-minute screen-off interval and a two-minute forced deep-idle cycle also resumed cleanly, preserving root and connectivity.
- The kernel recorded 616 successful suspends and zero resume-stage failures during the approximately six-hour uptime observed. The suspend-success counter did not advance during the USB-connected screen-off tests, so a long unplugged suspend remains unverified.
- USB charging increased the battery from 87% to 88%; battery temperature remained 31 C, health remained good, and all reported thermal zones stayed at status 0.
- The current-boot kernel log contained zero module-version, protected-export, unknown-symbol, Wi-Fi-not-ready, panic, oops or call-trace matches after testing.
- The Android crash buffer contained zero fatal app or native-process crashes after the controlled test sequence.

This is a successful controlled validation, not a substitute for longer daily use. The remaining unverified cases are an outdoor satellite fix, carrier/IMS calling with an installed SIM, and a long unplugged suspend. Keep the included exact official restore image available while evaluating the kernel.

Image SHA-256:

`bd47bd8162aaca03e1f11c77c33fd2976c7d43492a6f33d4696f2fc95977894a`

Official restore SHA-256:

`7e8ab39042c60977ba96a26a32ff9d79d49cc0c7debce57a5a9227c4fd10fa20`
