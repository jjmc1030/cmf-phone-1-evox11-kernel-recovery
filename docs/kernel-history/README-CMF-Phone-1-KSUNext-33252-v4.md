# KernelSU Next 33252 / SUExecFix v4

Target: CMF Phone 1 (`Tetris` / A015), Evolution X 11.10 GApps, Android 16,
GKI `6.1.134-android14-11`.

## Final change

This build updates the feature kernel from KernelSU Next 33229 to exact code
33252 and pairs the kernel with a Manager and `ksud` from the same revision:

- KernelSU Next commit: `1ce76ef55805697fcfa56aa18fb8dacd06b0dafb`
- runtime version: `3.3.0-38-g1ce76ef5`
- Manager/kernel/daemon code: `33252`
- kernel build marker: `#4`
- SUSFS: `2.2.0`

The patch keeps upstream KernelSU Next Manager identities and adds the local
Manager certificate identity. The private certificate key is not published.

## SU executable fix

The Linux 6.1 SUSFS path requires the `faccessat()` hook to use the resolved
`struct filename`. For an approved root profile, the SU handoff pre-opens
`/data/adb/ksud` with KernelSU credentials and executes the file descriptor via
`execveat(AT_EMPTY_PATH)`. This avoids a later pathname lookup failing when
SUSFS hides the daemon path in the caller's mount context.

## Verification

- kernel and modules built with pinned AOSP Clang `r487747b`;
- compile command contained `KSU_VERSION=33252`;
- 3,269 unique shared symbol CRC comparisons against 481 Evolution X modules
  passed with zero mismatches;
- all 15,998 kernel exports retained their prior CRC values;
- unpacked boot kernel matched the compiled image byte-for-byte;
- 64 MiB boot image AVB hash and signature verified;
- two Android boots passed with marker `#4`;
- kernel and `/data/adb/ksud` both reported 33252;
- `su -c id` returned UID 0 in `u:r:ksu:s0` from ADB and Termux;
- Wi-Fi reconnect, sleep/wake, F2FS I/O, CPU checksum and network tests passed;
- no current panic, oops, call trace, unknown-symbol or KernelSU fatal error.

## Checksum

```text
7b18feeee9c50c100650a61779dd54133debabada6f410710a477f6ec0215098  CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-SUExecFix-v4-KSUNext-33252-SUSFS-2.2.0-boot.img
```
