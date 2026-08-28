# CMF Phone 1 — Evolution X 11.10 GApps SUExecFix v2

Target: CMF Phone 1 (`Tetris`), Evolution X 11.10 GApps, Android 16, GKI `6.1.134-android14-11`.

This is a separate experimental boot image. It does not replace the earlier images or the official restore image in this folder.

## Diagnosis

The running `#1` kernel grants ADB shell visibility of `/system/bin/su`, but execution returns status 127 before a userspace `su` program starts. ADB shell and PID 1 use the same mount namespace, so the remaining likely cause is that `/data/adb/ksud` is missing or cannot be opened with its current label/access state.

This behavior agrees with KernelSU's current design: the upstream [sucompat refactor](https://github.com/tiann/KernelSU/pull/3521) requires `/data/adb/ksud` to exist and says the Manager must install it. The superficially similar [KernelSU Next issue #1196](https://github.com/KernelSU-Next/KernelSU-Next/issues/1196) concerned legacy/manual hooks and is not the correct patch for this 6.1 inline-hook kernel.

The installed randomized Manager package reports `v3.3.0-spoofed`, version code `33214`; the kernel driver remains KernelSU Next `33229` / v3.3.0.

## v2 handoff

For an allowed UID requesting `/system/bin/su`, v2 tries:

1. Open `ksud` in the caller's root with KernelSU credentials.
2. Open `ksud` from PID 1's root.
3. If both fail, execute `/system/bin/sh` with the granted KernelSU root profile.

The fallback is still protected by the KernelSU allowlist and chroot checks. It is intended to restore `su -c` and interactive Termux root so the missing or mislabeled `ksud` can be inspected. When the fallback is active, `su -v` and `su -V` may behave like shell options instead of returning KernelSU version information.

The build is marked `#2` in `uname -a`, without changing `6.1.134-android14-11` or the external-module compatibility string.

## Preserved features

- MediaTek Wi-Fi configuration from the working WiFiFix build
- KernelSU Next v3.3.0 / driver code 33229 and SUSFS v2.2.0
- Baseband Guard, DroidSpaces support, BBR/BBRv3, WireGuard, IP Set, IPv6 NAT
- CAKE, fq/fq_codel, CIFS, NTSync, BTF/eBPF, tmpfs xattrs and ACLs

## Flashing

Keep `CMF-Phone-1-EvolutionX-11.10-GApps-OFFICIAL-RESTORE-boot.img` nearby. This image belongs in `boot`, not `init_boot` or `vendor_boot`.

```text
fastboot devices
fastboot getvar current-slot
```

If the active slot is `b`:

```text
fastboot flash boot_b CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-SUExecFix-v2-KSUNext-33229-SUSFS-2.2.0-boot.img
fastboot reboot
```

Use `boot_a` instead if the active slot is `a`.

## Tests after boot

First prove that v2 is running:

```text
adb shell uname -a
```

It must contain `#2`.

Then test the root command and inspect `ksud` through the granted root profile:

```text
adb shell 'su -c "id; id -Z; ls -lZ /data/adb/ksud 2>&1"'
```

Also test in Termux:

```text
su -c id
```

Share the complete first command output. It will tell us whether real `ksud` executed or the root-shell fallback was required. If `ksud` is missing or mislabeled, repair it before treating the fallback as a permanent solution.

## Verification completed

- Kernel and modules compiled successfully with build marker `#2`.
- Required KernelSU, SUSFS, MediaTek Wi-Fi, Baseband Guard, BBRv3, WireGuard, NTSync, CIFS, BTF/eBPF, and tmpfs options remain enabled.
- The 64 MiB boot image has a valid SHA256_RSA2048 AVB footer and verified boot hash.
- A fresh unpack produced a kernel byte-identical to the rebuilt `Image`.

Hardware boot and root execution still require testing on the phone.
