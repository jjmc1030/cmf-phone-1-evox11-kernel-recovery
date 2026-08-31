# Compatibility and support matrix

Compatibility is limited to the exact builds below. ROM name and Android
version alone are not enough for safe `boot` or `vendor_boot` reuse.

| Target | Kernel | OrangeFox | Status |
| --- | --- | --- | --- |
| Evolution X 11.10 GApps build 2447 | v5 GApps image | v28 GApps image | ROM-matched release |
| Evolution X 11.10 Vanilla build 2446 | v5 Vanilla image | v28 Vanilla image | Live-tested together |
| Nothing OS 4.1 `B4.1-260812-1726` | v2 stock-module-trust image | v5 Nothing OS image | Live-tested together |
| Another Evolution X build | Repackage and revalidate | Rebuild from that build's `vendor_boot` | Unsupported until tested |
| Another Nothing OS build/OTA | Rebuild for its exact GKI and module signer | Rebuild from its exact `vendor_boot` | Unsupported until tested |
| Other ROM/device/Android version | Unsupported | Unsupported | Do not flash |

## Why the kernel is ROM-specific

The Evolution X images use Android 14 GKI 6.1.134 and ROM-specific AVB
fingerprints. The Nothing OS image uses GKI 6.1.162 and the public certificate
needed by its official protected module exports. Vendor and system modules must
match the kernel's KMI symbol versions and trust configuration.

Before adapting the kernel, compare the kernel release, module signer,
`Module.symvers`, protected exports, `vendor_dlkm`/`system_dlkm` module set,
load order, firmware and SELinux expectations.

## Why the recovery is ROM-specific

Recovery is a type-`RECOVERY` fragment inside header-v4 `vendor_boot`. The same
image contains the ROM's platform ramdisk, early modules, DTB, bootconfig,
first-stage fstab and AVB metadata. FBE decryption also depends on compatible
Trustonic, KeyMint, Gatekeeper, Health and VINTF components.

The GApps, Vanilla and Nothing OS OrangeFox images therefore use separate bases
even when their recovery UI code is identical. Never cross-flash them.

## Validated functions

Evolution X Vanilla v5/v28 passed repeated Android boot, KernelSU root, Wi-Fi,
FBE/internal storage, MTP read/write/delete, clock/battery checks and
non-destructive ADB sideload. GApps is separately packaged against build 2447;
do not substitute the Vanilla image.

Nothing OS kernel v2 passed Android boot, Wi-Fi, Bluetooth cycling, camera,
GNSS-service requests, KernelSU/SUSFS checks, suspend/resume and log audits.
Outdoor satellite TTFF, real SIM/IMS calling and long unplugged suspend remain
unverified.

Nothing OS OrangeFox v5 passed touch, decryption, storage, backup/read integrity,
direct ZIP, on-screen sideload/cancel, MTP service start/stop, fastbootd and
Android reboot. Restore-to-partition, Format Data, full ROM flashing, slot
changes, USB OTG and removable media were not repeated during its final
non-destructive qualification.

## OTA and restore guidance

- An OTA can replace `boot` and `vendor_boot` on the updated slot.
- Save original images from the exact installed build before flashing.
- After any OTA, rebuild and revalidate instead of reusing the old images.
- Verify SHA-256 and active slot before every flash.
- Do not erase data as the first response to a kernel or recovery boot problem.
