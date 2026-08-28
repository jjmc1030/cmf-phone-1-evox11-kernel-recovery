# CMF Phone 1 — Evolution X 11.10 GApps SUExecFix v1

Target: CMF Phone 1 (`Tetris`), Evolution X 11.10 GApps, Android 16, GKI `6.1.134-android14-11`.

This is a separate test boot image. The earlier working FeaturePack image and the official restore images were not overwritten.

## What was fixed

The installed kernel recognized `/system/bin/su` during file checks, but its SUSFS-integrated execution hook only replaced that path with `/data/adb/ksud`. The later pathname lookup failed for ADB shell and Termux, producing `su: inaccessible or not found` even after root access was granted in KernelSU Next Manager.

SUExecFix v1 opens `ksud` using KernelSU's own credentials and executes that already-open file through `execveat(..., AT_EMPTY_PATH)`. It also closes the temporary file descriptor if execution fails. This follows the file-descriptor method already used by KernelSU's alternate hook path.

The symptom also matches [KernelSU Next issue #1196](https://github.com/KernelSU-Next/KernelSU-Next/issues/1196), reported on Android 16.

## Preserved features

- KernelSU Next v3.3.0 / kernel version code 33229
- SUSFS v2.2.0
- The MediaTek Wi-Fi configuration from the working WiFiFix build
- Baseband Guard, DroidSpaces support, BBR/BBRv3, WireGuard, IP Set, IPv6 NAT, CAKE, fq/fq_codel, CIFS, NTSync, BTF/eBPF, tmpfs xattrs and ACLs

See `README-CMF-Phone-1-FeaturePack.md` in this folder for the full feature and compatibility notes.

## Flashing

Keep `CMF-Phone-1-EvolutionX-11.10-GApps-OFFICIAL-RESTORE-boot.img` nearby. This kernel belongs in `boot`, not `init_boot` or `vendor_boot`.

Check the active slot:

```text
fastboot devices
fastboot getvar current-slot
```

For slot `b`:

```text
fastboot flash boot_b CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-SUExecFix-v1-KSUNext-33229-SUSFS-2.2.0-boot.img
fastboot reboot
```

Use `boot_a` instead if the current slot is `a`.

## Tests after boot

Keep ADB Shell and Termux granted in KernelSU Next Manager, then run:

```text
adb shell 'su -v; su -V; su -c "id; id -Z"'
```

In Termux:

```text
su -c id
```

Expected: `su` is found, `su -c id` reports UID 0, and a KernelSU version is printed. Then force-stop/reopen BindHosts and rebuild its hosts file.

Also confirm Wi-Fi and mobile data still work before testing optional networking features.

## Verification completed

- Kernel and modules compiled successfully with the pinned AOSP Clang toolchain.
- The required KernelSU, SUSFS, MediaTek Wi-Fi, Baseband Guard, BBRv3, WireGuard, NTSync, CIFS, BTF/eBPF, and tmpfs options remain enabled.
- The 64 MiB boot image has a valid SHA256_RSA2048 AVB footer and boot hash.
- A fresh unpack of the final image produced a kernel byte-identical to the rebuilt `Image`.

Hardware boot and `su` execution still require testing on the phone.
