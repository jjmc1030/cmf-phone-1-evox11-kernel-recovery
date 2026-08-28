# CMF Phone 1 — Evolution X 11.10 GApps SUExecFix v3

Target: CMF Phone 1 (`Tetris`), Evolution X 11.10 GApps, Android 16, GKI `6.1.134-android14-11`.

This is a separate test boot image. It does not replace the v2 image or the official GApps restore image in this folder.

## Confirmed v2 diagnosis

The phone booted v2 and reported kernel build marker `#2`. Direct raw `execve` and `execveat` tests of `/system/bin/su` both reached KernelSU and produced:

```text
uid=0(root) gid=0(root) groups=0(root) context=u:r:ksu:s0
```

Normal ADB and Termux commands still failed before execution because their shell first calls `faccessat()` to check whether `su` is executable. The local KernelSU/SUSFS handler used a userspace-string pointer signature, but this 6.1 kernel passes an already parsed `struct filename **`. That ABI mismatch made the executable check fail. The same interface correction is present in the maintainer's newer [`dev-susfs` update](https://github.com/pershoot/KernelSU-Next/commit/a8e3a5ef).

The root diagnostic also confirmed that `/data/adb/ksud` exists, is executable, is 4,907,712 bytes, and has the expected `u:object_r:ksu_file:s0` label. SUSFS hides it from the original shell task before the KernelSU root profile is installed.

## v3 fixes

- Corrects the 6.1 SUSFS `faccessat` handler to accept `struct filename **`, making the virtual `/system/bin/su` pass normal shell and Termux executable checks.
- Keeps the tested fd-based `execveat(AT_EMPTY_PATH)` handoff from v2.
- After the allowlisted caller receives its KernelSU root profile and mount namespace, retries `/data/adb/ksud` so the real daemon handles `su`, `su -v`, and modules normally.
- Retains the allowlist- and chroot-protected root-shell fallback only if the real daemon remains unavailable.

The build is marked `#3` in `uname -a`, without changing the module compatibility release `6.1.134-android14-11`.

## Preserved features

- MediaTek Wi-Fi configuration from the working WiFiFix build
- KernelSU Next v3.3.0 / driver code 33229 and SUSFS v2.2.0
- Baseband Guard and DroidSpaces kernel support
- BBR/BBRv3, WireGuard, IP Set, IPv6 NAT, TTL/CONNMARK support
- CAKE, fq/fq_codel, CIFS, NTSync, BTF/eBPF, tmpfs xattrs and ACLs

## Flashing

Keep `CMF-Phone-1-EvolutionX-11.10-GApps-OFFICIAL-RESTORE-boot.img` nearby. Flash this image only to `boot`; do not flash it to `init_boot` or `vendor_boot`.

```text
fastboot devices
fastboot getvar current-slot
```

For active slot `b`:

```text
fastboot flash boot_b CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-SUExecFix-v3-KSUNext-33229-SUSFS-2.2.0-boot.img
fastboot reboot
```

Use `boot_a` instead when the active slot is `a`.

## Tests after boot

```text
adb shell uname -a
adb shell 'echo "su=$(command -v su)"; su -v; su -V; su -c "id; id -Z; ls -lZ /data/adb/ksud"'
```

The first command must contain `#3`. The root test should report UID 0 with `u:r:ksu:s0`. Then test Termux:

```text
su -c id
```

## Verification completed

- Kernel and modules compiled successfully with build marker `#3`.
- Required KernelSU, SUSFS, MediaTek Wi-Fi, Baseband Guard, BBRv3, WireGuard, NTSync, CIFS, BTF/eBPF, and tmpfs options remain enabled.
- A fresh unpack produced a kernel byte-identical to the rebuilt `Image`.
- The 64 MiB boot image has a valid SHA256_RSA2048 AVB footer and boot hash, signed with the same public AOSP AVB test key used by the official Evolution X GApps image.
- OS version, fingerprint, partition name, salt, rollback settings, and AVB public-key fingerprint match the official base.

Hardware boot, Wi-Fi, and normal ADB/Termux `su` still require testing on the phone.
