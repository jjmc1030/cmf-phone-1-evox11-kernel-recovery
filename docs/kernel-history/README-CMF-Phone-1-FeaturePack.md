# CMF Phone 1 — Evolution X 11.10 FeaturePack kernel

Target: CMF Phone 1 (`Tetris`), Evolution X 11.10, Android 16, GKI `6.1.134-android14-11`.

This is a separate test build. The earlier working and official-restore images in this folder were not overwritten.

## Important Wi-Fi correction

The earlier custom kernel used the generic GKI configuration. That configuration disabled `ARCH_MEDIATEK`, `CFG80211`, and `MAC80211`, while Evolution X 11.10's official kernel enables them. This FeaturePack was rebuilt from the configuration extracted from the official Evolution X kernel and retains those MediaTek/Wi-Fi settings.

Static compatibility verification covered all 481 modules shipped by Evolution X. There were 3,269 module-to-kernel CRC comparisons and zero mismatches. All 15,631 kernel exports shared with the earlier build retain the same CRCs.

## Included features

- KernelSU Next v3.3.0, kernel version code 33229
- SUSFS v2.2.0
- Baseband Guard at upstream commit `a54e0dc6`
- DroidSpaces GKI support: SYSVIPC kABI padding, IPC/PID/User namespaces, POSIX queues, devtmpfs, tmpfs xattrs and ACLs
- BBRv1 (`bbr`) and BBRv3 (`bbr3`); CUBIC remains the safe boot default
- WireGuard, IP Set, IPv6 NAT, TTL/HL targets, connmark
- CAKE, fq, and fq_codel queueing
- CUBIC, BIC, Westwood, and HTCP congestion control
- CIFS/SMB with xattr and POSIX support
- NTSync
- BTF, eBPF events, and FUSE-BPF
- Experimental Unicode path-filtering hardening

The pre-5.16 ptrace fix was not applied because this is a 6.1 kernel and the fix is not applicable.

Baseband Guard is enforcing for protected baseband-related block devices. Boot and recovery blocking are disabled so kernel/recovery flashing remains possible. ZRAM and loop devices are explicitly allowed so DroidSpaces image-backed root filesystems can work.

## Which image to use

- Use the `GApps-FeaturePack-WiFiFix` boot image with the Evolution X GApps build.
- Use the `Vanilla-FeaturePack-WiFiFix` boot image only with the Evolution X Vanilla build.
- The AnyKernel3 ZIP is for a compatible custom recovery; stock recovery normally will not install it.

## Fastboot installation

Keep a restore image available. Reboot to the bootloader and check the active slot:

```text
fastboot devices
fastboot getvar current-slot
```

If the current slot is `b`, flash the GApps build with:

```text
fastboot flash boot_b CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-KSUNext-33229-SUSFS-2.2.0-boot.img
fastboot reboot
```

Use `boot_a` instead if the current slot is `a`. Do not flash the Vanilla image over a GApps ROM.

## First-boot checks

1. Confirm Wi-Fi can be enabled and can reconnect after one reboot.
2. Open KernelSU Next Manager v3.3.0 and confirm the kernel reports version 33229.
3. In DroidSpaces, run the requirements check. With SUSFS, disable **HIDE SUS MOUNTS FOR ALL PROCESSES** or containers may fail to start.
4. Leave CUBIC as the default initially. After stability testing, `bbr` or `bbr3` can be selected through the usual TCP congestion-control sysctl.

The boot images were unpacked after repacking, their embedded kernel was byte-compared with the compiled Image, and their AVB footer, signature, and boot hash were verified. Hardware boot and Wi-Fi validation still need to be performed on the phone.
