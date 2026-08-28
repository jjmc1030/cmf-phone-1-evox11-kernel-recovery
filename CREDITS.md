# Credits and upstream sources

Thank you to every upstream maintainer and contributor whose work made this
CMF Phone 1 port possible. Links and revisions below document the exact local
bases used during development.

## Android, device, and toolchain bases

| Project | Credit / purpose | Revision used |
| --- | --- | --- |
| [Android common kernel](https://android.googlesource.com/kernel/common) | Google and Linux kernel contributors; GKI 6.1 base | `8dc7d7757edd922ed1e79851711dc2c47bfcf227` (`android14-6.1-2025-05_r1`) |
| [Evolution X CMF Phone 1 device tree](https://github.com/Evolution-X-Devices/device_nothing_Tetris) | Evolution X device maintainers; ROM/device configuration reference | `e5938ea8fb1d` |
| [Evolution X CMF Phone 1 kernel artifacts](https://github.com/Evolution-X-Devices/device_nothing_Tetris-kernel) | Evolution X device maintainers; ROM-matched kernel reference | `36a08d06a6b5` |
| [AOSP Clang prebuilts](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86) | Android LLVM toolchain | `eed2fff8b93ce059eea7ccd8fc5eee37f8adb432` / `clang-r487747b` |
| [Android Verified Boot](https://android.googlesource.com/platform/external/avb) | Google; AVB inspection and verification tooling | `c5066a96caa7bf4150c0a8cc8cc14ab81733fdc7` |

## Kernel features

| Project | Credit / purpose | Revision used |
| --- | --- | --- |
| [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next) | KernelSU Next maintainers and KernelSU contributors; kernel root framework and Manager | Upstream project; final device build uses code `33252` from the SUSFS fork below |
| [pershoot/KernelSU-Next](https://github.com/pershoot/KernelSU-Next) | `dev-susfs` integration and Linux 6.1 SU compatibility base | Final `1ce76ef55805697fcfa56aa18fb8dacd06b0dafb` (`3.3.0-38-g1ce76ef5`, code `33252`); earlier `26fded805206ae4542f4745e09cc465412994492`; the [`faccessat` correction](https://github.com/pershoot/KernelSU-Next/commit/a8e3a5ef) informed the device fix |
| [SUSFS4KSU](https://gitlab.com/simonpunk/susfs4ksu) | Simon Punk and contributors; SUSFS v2.2.0 | `0ff932799d89` |
| [Baseband Guard](https://github.com/vc-teahouse/Baseband-guard) | vc-teahouse contributors; LSM protection for critical baseband device nodes | `a54e0dc6cf0a` |
| [DroidSpaces-OSS](https://github.com/ravindu644/Droidspaces-OSS) | Ravindu and contributors; Android/Linux container kernel requirements | `dfb6eca9255b` |
| [WildKernels kernel patches](https://github.com/WildKernels/kernel_patches) | WildKernels contributors; BBRv3 and related GKI feature references | `757201d983e2` |
| [WildKernels GKI KernelSU SUSFS](https://github.com/WildKernels/GKI_KernelSU_SUSFS) | WildKernels contributors; feature selection and integration reference | `8863e4e04ee5` |
| [AnyKernel3](https://github.com/osm0sis/AnyKernel3) | osm0sis and contributors; flashable kernel packaging | `af770f7b16cf8f8eb7c68614b2a693b3b361c90c` |

Networking and filesystem features such as WireGuard, BBR, CAKE, fq/fq_codel,
IP Set, netfilter targets, CIFS, BTF/eBPF, and tmpfs ACL/xattr support also rely
on the work of their respective Linux kernel subsystem maintainers and
contributors.

## Recovery work

| Project | Credit / purpose | Revision used |
| --- | --- | --- |
| [OrangeFox Android 16 bootable recovery](https://github.com/OrangeFox16/android_bootable_recovery) | OrangeFox Recovery Project, Team Win, and contributors; Android 16 recovery backend | `bb7a652852178893b9388e7e06b86995c2fd3908` |
| [OrangeFox Android 16 vendor recovery](https://github.com/OrangeFox16/android_vendor_recovery) | OrangeFox Recovery Project; `fox_16.0-R12` vendor base | `f243e0b7bb863d51e11c11aeca6ff892751eabf6` |
| [Official OrangeFox vendor/recovery](https://gitlab.com/OrangeFox/vendor/recovery/-/tree/fox_16.0-R12) | OrangeFox Recovery Project; official R12 Android 16 source and UI reference | `fox_16.0-R12` |
| [CMF Phone 1 TWRP device tree](https://github.com/HackySoftOfficial/twrp_device_nothing_Tetris) | HackySoftOfficial, Heptex, HpDevFox, Ashwani, and contributors; original Tetris recovery tree | `3aaf62423b7d528e6105d159dcea9c10a37c697f` |
| [OFR_TB373FU_A16](https://github.com/killindodo/OFR_TB373FU_A16) | killindodo and contributors; Android 16 MediaTek OrangeFox reference | `c8630e58e14599f4f9787f5742e2e4bfd7343ae7` |
| [Team Win Recovery Project](https://twrp.me/) | Team Win and contributors; recovery foundation, UI, storage, and device infrastructure | Upstream through OrangeFox sources |
| [Nothing Open Source](https://github.com/NothingOSS) | Nothing Technology Limited; device kernel sources and related GPL materials | Device-family source reference |

The R12 interface patch is a port of OrangeFox's own R12 work to its Android 16
fork; it should not be interpreted as original ownership of OrangeFox artwork,
fonts, icons, themes, or UI code.

Android architecture documentation used to define the published compatibility
limits:

- [AOSP vendor boot partitions](https://source.android.com/docs/core/architecture/partitions/vendor-boot-partitions)
- [AOSP kernel module support](https://source.android.com/docs/core/architecture/kernel/kernel-module-support)
- [AOSP stable KMI requirements](https://source.android.com/docs/core/architecture/kernel/stable-kmi)
- [CMF Phone 1 Nothing OS 4.0 / Android 16 changelog](https://nothing.community/en/d/50171-cmf-phone-1-nothing-os-b40-251216-1717-changelog)

## Testing and integration

Integration, device testing, iterative boot/recovery diagnosis, safe flash
helpers, the Linux 6.1 KernelSU `faccessat()`/fd-exec correction, and the final
Android 16 recovery decryption work were performed by the **CMF Phone 1
community project** with assistance from **OpenAI Codex**.
