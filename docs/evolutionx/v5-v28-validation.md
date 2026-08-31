# CMF Phone 1 Evolution X 11.10 dual-ROM build

Target: CMF Phone 1 (`Tetris` / A015), Android 16, Evolution X 11.10 official
builds dated 2026-08-19.

This package has separate verified-boot images for:

- GApps build `2447`
- Vanilla build `2446`

Do not interchange these files with Nothing OS or another ROM release. The
kernel payload is identical, but each image preserves its matching ROM's AVB
fingerprint. The OrangeFox images also start from the matching official
`vendor_boot` image.

## Kernel v5

Use exactly one image:

- GApps: `CMF-Phone-1-EvolutionX-11.10-FeaturePack-SecurityFix-v5-KSUNext-33252-SUSFS-2.2.0-GApps-boot.img`
- Vanilla: `CMF-Phone-1-EvolutionX-11.10-FeaturePack-SecurityFix-v5-KSUNext-33252-SUSFS-2.2.0-Vanilla-boot.img`

The raw kernel in both files is byte-identical. It reports
`6.1.134-android14-11 #5` and includes KernelSU Next `33252`, SUSFS `2.2.0`,
Baseband Guard, WireGuard, BBR/BBR3, CAKE/fq/fq_codel, IP Set, IPv6 NAT,
connmark, CUBIC/BIC/Westwood/HTCP, CIFS, tmpfs xattrs/ACLs, NTSync,
BTF/eBPF, FUSE-BPF, namespaces and the other feature-pack options carried by
v4.

Security/compatibility changes from v4:

- `CONFIG_BPF_UNPRIV_DEFAULT_OFF=y` establishes the safer early kernel
  default. Evolution X later changes the live sysctl back to `0`, so v5 must
  not be described as permanently disabling unprivileged eBPF. A v6 attempt
  to lock it at `1` bootlooped and was rejected; privileged/root eBPF and BTF
  remain available on v5.
- `CONFIG_BBG_BLOCK_RECOVERY` remains disabled. Enabling it would prevent a
  custom recovery from installing ROM payloads.
- No Wi-Fi driver or module ABI was changed. Both variants ship the same
  kernel and use their ROM-provided MediaTek modules.

### Optional post-boot eBPF lockdown

`EvolutionX-PostBoot-eBPF-Lockdown-KSU-v1.0.zip` safely sets
`kernel.unprivileged_bpf_disabled=1` after Android reports boot completion and
an additional ten-second delay. It deliberately does not enforce the setting
during early boot, when Evolution X initializes its BPF programs. Privileged
and root eBPF access remains available.

The module was installed on Vanilla build 2446 and passed a cold Android reboot:
its log recorded `before=0 after=1`, KernelSU root remained functional, and
Wi-Fi reconnected over 802.11ax at 480 Mbps. Disable or remove the module in
KernelSU Manager and reboot if unprivileged eBPF is required by an application.
The same delayed mechanism is intended for the matching GApps build 2447, but
that flavor has not been live-flashed during this Vanilla test session.

The installed `/data/adb/ksud` already reports `33252` and matches this kernel.
The two `nsfs` policy warnings came from Zygisk Next 1.5.0, not KernelSU. The
ROM does not define an `nsfs` SELinux type, so the non-applicable rule was
removed with a backup at:

`/data/adb/modules/zygisksu/sepolicy.rule.codex-backup-20260830`

The fix was verified after reboot: the two failed `nsfs` commands no longer
appear in the KernelSU boot log.

## OrangeFox R12.0 v28

Use exactly one image:

- GApps: `CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-v28-DualROM-TimeResourceFix-GApps-vendor_boot.img`
- Vanilla: `CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-v28-DualROM-TimeResourceFix-Vanilla-vendor_boot.img`

Both contain the same OrangeFox recovery and preserve the official, identical
platform ramdisk, DTB and bootconfig. Their AVB build fingerprints match their
respective ROM variants.

Changes from the device-tested v27 baseline:

- The visible and saved OrangeFox timezone value is now synchronized with the
  timezone actually applied to the recovery clock.
- A missing next animation frame is treated as the normal end of an animation,
  removing the false `indeterminate033` resource error without hiding genuine
  image-load failures.
- All v27 sideload/FUSE acknowledgement, sideload cancellation, A/B payload,
  safe recovery reflash, format-data, FBE/decryption, MTP and mount fixes are
  retained.
- The AIDL Health declaration is at `vendor/etc/vintf/manifest.xml`; the HIDL
  Health 2.1 compatibility fragment remains under
  `vendor/etc/vintf/manifest/`.

## Validation status

- Kernel and OrangeFox source builds completed successfully.
- All four images are exactly 64 MiB and pass AVB SHA256_RSA2048 verification.
- Both boot images unpack to raw kernel SHA-256
  `09b8e4293add944c1876cb1d5e88ff06c92996222ae00df2ec14aa462e194436`.
- Both OrangeFox images contain platform ramdisk SHA-256
  `87972876c52eee7ffdd9b70f60d1ec8065823a374742fa48fbc7ec033e213bdc`,
  matching both official ROMs exactly.
- Both OrangeFox images contain recovery ramdisk SHA-256
  `59464a1806d1b99214ea127e38cdf506b71cc7f7da71e82c99fcce69bb30ab2f`.
- Vanilla v5 and v28 are installed on the connected build `2446`, slot A.
  Their live partition hashes match this package exactly.
- Android boot completed repeatedly on v5. KernelSU root reports `33252`, and
  Wi-Fi associated over 802.11ax at 480 Mbps during the final test.
- The optional post-boot eBPF lockdown module passed an additional Android
  reboot and held `/proc/sys/kernel/unprivileged_bpf_disabled` at `1` without
  disrupting KernelSU root or Wi-Fi.
- OrangeFox v28 booted successfully. Metadata and FBE user 0 decryption
  succeeded; `/data` and `/sdcard` mounted read/write; 222 GB was visible.
- MTP exposed Internal Storage and passed a host-to-phone copy/read/delete
  roundtrip.
- Recovery time was correct and both `tw_time_zone` variables matched the
  applied timezone. Battery capacity reported 89%, matching Android.
- A non-destructive ZIP passed ADB sideload. Recovery returned from sideload
  to normal ADB automatically with status 0 and no starting/finishing/cancel
  hang.
- The rejected v6 hard-lock build and its warning are isolated under
  `rejected-v6-hardlock-bootloop/`. Do not flash those files.

## Restore images

Matching official `boot` and `vendor_boot` restore images for both variants are
included. Verify files against `SHA256SUMS-CMF-Phone-1-DualROM-v5-v28` before
flashing.

Flashing an image for the wrong ROM build or partition can make the phone
unbootable. Keep the matching restore pair available in bootloader fastboot.
