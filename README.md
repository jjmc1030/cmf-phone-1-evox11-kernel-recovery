# CMF Phone 1 Android 16 kernel and OrangeFox R12

Unofficial development release for the CMF Phone 1 (`Tetris` / A015), built
and tested with Evolution X 11.10 GApps on Android 16. It contains a
feature-packed Android 14/6.1 GKI kernel and an OrangeFox R12.0 recovery port.

> [!CAUTION]
> This is device-specific low-level software. Keep ROM-matched `boot` and
> `vendor_boot` restore images before testing. Verify every SHA-256, identify
> the active slot, and flash only the documented partition. Never format
> `/data` to troubleshoot recovery decryption.

## Final tested builds

| Component | Final version | On-device result |
| --- | --- | --- |
| Kernel | `6.1.134-android14-11 #4` | Android boots normally; Wi-Fi, mobile data, sleep/wake, F2FS I/O and networking tested |
| KernelSU Next | `3.3.0-38-g1ce76ef5`, code `33252` | Kernel, Manager and `/data/adb/ksud` match; ADB and Termux `su` return UID 0 in `u:r:ksu:s0` |
| SUSFS | `2.2.0` | Integrated with KernelSU Next; BindHosts verified as a real hosts-file mount |
| Kernel feature pack | BBG, DroidSpaces prerequisites, BBR/BBRv3, WireGuard, IP Set, IPv6 NAT, TTL/HL, CONNMARK, CAKE, fq/fq_codel, CIFS, NTSync, BTF/eBPF, tmpfs xattrs/ACLs | Built, configuration-checked and boot-tested |
| OrangeFox | R12.0 Android 16, stock-platform v17 | Boots and remains stable; `/data`, `/metadata` and internal storage mount read-write; device-side MTP/ADB active; battery and clock fixes retained; safe data-format teardown added |

The latest recovery soak kept recovery, logd, Health, Trustonic, KeyMint,
Gatekeeper and Keystore2 alive without VINTF, F2FS, dm-crypt, panic or fatal
errors. Physical touch should still be confirmed by each tester after flashing.
The v17 Format Data fix was compiled and its non-destructive prerequisites were
validated, but the irreversible format itself was not run during final testing.

## Repository layout

- `kernel/config` — final ROM-compatible kernel configuration.
- `kernel/patches` — feature, KernelSU/SUSFS and SU executable-fix history.
- `kernel/scripts` — pinned reproducible build scripts, including final v4.
- `recovery/device/nothing/Tetris` — redistributable Android 16 device tree.
- `recovery/patches` — OrangeFox R12 UI port, v15 runtime/decryption fixes, and v16/v17 data-format fixes.
- `recovery/scripts` — guarded flash/restore and diagnostic helpers.
- `docs` — version history, final validation and compatibility notes.
- `CREDITS.md` — upstream projects, maintainers, links and pinned revisions.

Restricted MediaTek source and private device logs are not published. See
`recovery/device/nothing/Tetris/EXCLUDED_INPUTS.md` and `LICENSES.md`.

The complete modified kernel source snapshot, including the vendored KernelSU
33252 kernel code, is published separately at
<https://github.com/jjmc1030/cmf-phone-1-evox11-kernel-source>.

## Kernel build and installation

Rebuild the final kernel with:

```bash
kernel/scripts/build-cmf-evox-featurepack-suexecfix-v4-kernel.sh /path/to/work
```

The script pins Android common kernel `android14-6.1-2025-05_r1`, the exact
KernelSU Next SUSFS revision used for code 33252, and AOSP Clang `r487747b`.
It applies the published common-kernel and KernelSU patches, verifies important
features, and emits `Image.lz4`.

Download the final boot image from the GitHub release and verify its checksum.
In bootloader fastboot mode:

```text
fastboot getvar current-slot
fastboot flash boot_b CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-SUExecFix-v4-KSUNext-33252-SUSFS-2.2.0-boot.img
fastboot reboot
```

Use `boot_a` only when slot A is active. Do not flash this file to `init_boot`,
`vendor_boot`, or any other device.

## OrangeFox installation

The v17 release image is a complete 64 MiB `vendor_boot` built with the tested
Evolution X 11.10 platform ramdisk, DTB and bootconfig. Place the downloaded
asset in `release-assets/`, keep an exact ROM-matched restore image outside the
repository, then run:

```bash
recovery/scripts/flash-orangefox-or-restore.sh install
```

The helper verifies the release checksum, requires exactly one bootloader
fastboot device, rejects fastbootd, detects the active slot and asks for a
confirmation phrase. For restore, provide your own image:

```bash
RESTORE_IMAGE=/absolute/path/to/rom-matched-vendor_boot.img \
RESTORE_SHA256=<verified-sha256-from-your-rom-package> \
  recovery/scripts/flash-orangefox-or-restore.sh restore
```

Do not flash the recovery image to `boot`, `init_boot`, or a standalone
`recovery` partition.

## ROM compatibility

| Target | Kernel | OrangeFox v17 image |
| --- | --- | --- |
| Evolution X 11.10 GApps, tested build | **Supported and tested** | **Supported and tested** |
| Evolution X 11.10 Vanilla on the identical firmware/platform build | Likely compatible, not tested | Rebuild/merge from that ROM's `vendor_boot` unless its platform/DTB/bootconfig hashes match exactly |
| Nothing OS 4.0 / Android 16 | Not certified; requires KMI and vendor-module comparison first | **Do not flash this Evolution X image directly.** Merge the OrangeFox recovery fragment into the stock ROM's own `vendor_boot` and test decryption |
| Other Android 16 custom ROMs | Only if the CMF Phone 1 uses the same 6.1 GKI KMI and compatible vendor modules | ROM-specific `vendor_boot` merge required; crypto, Trustonic, fstab and firmware must match |
| Android 15, Android 17, or another device | Unsupported | Unsupported |

The kernel boot image has no ramdisk, which makes it less ROM-coupled than the
recovery image, but it is not universal. GKI vendor modules still depend on a
compatible Kernel Module Interface. The recovery is more tightly coupled:
Android vendor boot v4 carries platform/recovery ramdisk fragments, DTB and
bootconfig, and recovery decryption depends on the ROM's vendor security stack.

An OTA may replace `boot` or `vendor_boot`. After any ROM/firmware update,
restore the new ROM images first and repeat compatibility checks before
reapplying this work. See `COMPATIBILITY.md` for the full matrix and rationale.

## Release checksums

```text
7b18feeee9c50c100650a61779dd54133debabada6f410710a477f6ec0215098  CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-SUExecFix-v4-KSUNext-33252-SUSFS-2.2.0-boot.img
a2a6034671f822c173abe719c5c7d9d69325cbf92e1422ff70b49176a20edb62  CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-StockPlatform-v17-DataFormatFix-vendor_boot.img
05ac9caad5179a1829037e26139566b6fcffeee09f50491145aadb8f67757ef3  KernelSU-Next-v3.3.0-33252-CMF-local-manager.apk
8ed123a0d118ef4b5c19b427a5763c17ced11f5f6f84189c6cfdd900242e0af5  CMF-Phone-1-MediaTek-WiFi-Init-Config-Fix-KernelSU-v2.zip
```

## Credits and licensing

This is an integration and device-porting project, not ownership of the
upstream work. See `CREDITS.md` for exact acknowledgements and source revisions
and `LICENSES.md` for the mixed-license notice. CMF, Nothing, Evolution X,
KernelSU, OrangeFox and TWRP names belong to their respective owners.
