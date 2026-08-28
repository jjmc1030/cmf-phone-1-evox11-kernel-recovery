# Compatibility and support matrix

## What was actually tested

The release was tested on one CMF Phone 1 (`Tetris` / A015) running the supplied
Evolution X 11.10 GApps Android 16 build and its matching firmware. “Supported”
below means this exact combination, not every build carrying the same ROM name.

| Target | Final kernel boot image | Final OrangeFox v17 `vendor_boot` |
| --- | --- | --- |
| Tested Evolution X 11.10 GApps build | Supported and tested | Supported and tested |
| Evolution X 11.10 Vanilla, identical firmware/platform | Expected to be a good candidate, but not tested | Use a ROM-matched merge unless platform ramdisk, DTB and bootconfig hashes are identical |
| Nothing OS 4.0 / Android 16 | Unverified; do not assume compatibility | Incompatible as a direct flash; a stock-platform merge and new decryption test are required |
| Another Android 16 custom ROM on CMF Phone 1 | Unverified; requires KMI/module validation | Incompatible as a direct flash unless all platform inputs match exactly |
| Android 15, Android 17 or another phone | Unsupported | Unsupported |

Nothing OS 4.0 for CMF Phone 1 is based on Android 16, but the Android version
alone is not enough to make a low-level image compatible. See the official
[Nothing OS 4.0 changelog](https://nothing.community/en/d/50171-cmf-phone-1-nothing-os-b40-251216-1717-changelog).

## Why the kernel is not universal

The published `boot.img` uses boot header v4 and contains the kernel without a
ramdisk. That reduces ROM coupling, but the device still loads hardware-specific
modules from its vendor ramdisk and vendor partitions. Android's GKI design
requires those modules to match the kernel's Kernel Module Interface (KMI).

Before using the kernel with another ROM, compare at least:

- device and SoC: CMF Phone 1 / MT6878 only;
- kernel family and release: Android 14 GKI 6.1, matching `6.1.134-android14-11`;
- exported symbol CRCs required by every vendor module;
- `vendor_boot`, `vendor_dlkm` and `system_dlkm` module set and load order;
- firmware generation, SELinux policy and Android boot image properties.

The tested Evolution X modules passed 3,269 unique shared-symbol CRC comparisons
with zero mismatches, and all 15,998 kernel exports kept their previous CRCs.
Repeat those checks for every different ROM or firmware build.

References:

- [AOSP kernel module support](https://source.android.com/docs/core/architecture/kernel/kernel-module-support)
- [AOSP stable KMI requirements](https://source.android.com/docs/core/architecture/kernel/stable-kmi)
- [AOSP GKI kernel overview](https://source.android.com/docs/core/architecture/kernel)

## Why the recovery is ROM-specific

CMF Phone 1 recovery is a type-`RECOVERY` ramdisk fragment inside boot-header-v4
`vendor_boot`. The same image also carries ROM/platform-specific components:

- type-`PLATFORM` vendor ramdisk and early kernel modules;
- DTB and bootconfig;
- first-stage fstab and logical-partition behavior;
- Trustonic, KeyMint, Gatekeeper, Health and VINTF expectations;
- metadata-encryption and file-based-encryption configuration;
- AVB footer, key identity and partition metadata.

The final v17 image deliberately combines the tested OrangeFox recovery
fragment with the tested Evolution X platform fragment. Flashing that complete
image on Nothing OS or a different custom ROM would replace that ROM's platform
ramdisk and can cause a recovery loop, broken hardware, or a normal-boot failure.

For another ROM, unpack that ROM's own `vendor_boot`, retain its platform
ramdisk, DTB, bootconfig and AVB properties, replace only the recovery fragment,
then rebuild, sign and test. Data decryption is not considered compatible until
the new image can mount `/data` and `/data/media/0` read-write without formatting.

Reference: [AOSP vendor boot partitions](https://source.android.com/docs/core/architecture/partitions/vendor-boot-partitions).

## OTA and slot guidance

- A/B OTAs can replace `boot` and `vendor_boot` on the updated slot.
- Keep restore images from the exact ROM build currently installed.
- After an OTA, do not reuse an older full `vendor_boot`; rebuild the recovery
  merge from the new ROM base.
- Always verify the active slot and image checksum before flashing.
- Never use these files on a device other than CMF Phone 1.
