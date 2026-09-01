# v2.1.0 — Nothing OS 4.1 qualified stable final release

## Nothing OS 4.1 stable pair

- Replaced the Nothing OS kernel v2 recommendation with FeaturePack v4 for
  exact build `B4.1-260812-1726`.
- Added dynamic Shadow Call Stack, NTSync, duplicate trace-hook and complete
  Android 16K page-size migration fixes. The v3 `vma_pad_pages` regression no
  longer reproduces.
- All requested kernel feature probes and controlled CPU/F2FS/network,
  Wi-Fi/Bluetooth, camera/location/thermal and log checks passed.
- Replaced OrangeFox v5 with v8. v8 fixes the invalid v7 VINTF overlay and the
  ADB sideload SIGPIPE/recovery restart path.
- v8 passed touch, FBE/internal storage, real bidirectional MTP transfer, two
  consecutive sideload cycles, post-sideload mounting and VINTF/Health checks.
- v7 is withdrawn and must not be flashed.

This stable designation applies only to CMF Phone 1 on Nothing OS 4.1 build
`B4.1-260812-1726`. Other builds and ROMs are not interchangeable.

## Final maintainer release

This is the final planned release from the current maintainer. The work was
developed as a side project, and there is no longer enough time to continue
regular kernel or recovery development. The complete source and reproducible
patches remain public in the hope that the CMF Phone 1 community will take over
OrangeFox maintenance and, if possible, continue the kernel as well. Thank you
to everyone who tested, contributed and helped debug the project.

# v2.0.0 — ROM-specific Evolution X and Nothing OS builds

## Evolution X 11.10

- Added separate FeaturePack v5 boot images for GApps build 2447 and Vanilla
  build 2446, preserving each ROM's AVB fingerprint.
- Added separate OrangeFox R12 v28 `vendor_boot` images built from each ROM's
  own platform image.
- Retained KernelSU Next 33252, SUSFS 2.2.0, Baseband Guard and the complete
  networking/filesystem feature pack.
- Set the safe early `CONFIG_BPF_UNPRIV_DEFAULT_OFF=y` default without the
  incompatible permanent v6 lock. v6 bootlooped and was rejected.
- Added the optional, delayed Evolution X post-boot eBPF lockdown module.
- v28 retains the ROM ZIP, recovery reflash, payload, sideload/FUSE,
  cancellation, FBE, MTP, mount, data-format, battery and clock fixes.
- Vanilla v5/v28 passed live boot, root, Wi-Fi, decryption, MTP and sideload
  qualification.

## Nothing OS 4.1

- Added FeaturePack kernel v2 for exact build `B4.1-260812-1726` on GKI
  6.1.162.
- Added the exact stock public module-signing certificate to the trusted keyring,
  fixing the v1 Bluetooth/Wi-Fi protected-export failure without publishing a
  private key.
- Live-tested Wi-Fi, Bluetooth cycling, camera, GNSS services, KernelSU/SUSFS,
  suspend/resume and current-boot error logs.
- Added OrangeFox R12 v5 merged with the exact Nothing OS platform ramdisk, DTB,
  bootconfig and AVB properties.
- Live-tested touch, PIN/FBE decryption, internal storage, backup integrity,
  direct ZIP, on-screen sideload/cancel, MTP service transitions, fastbootd and
  system reboot.

## Published assets

- Evolution X v5 GApps and Vanilla `boot.img`
- Evolution X OrangeFox v28 GApps and Vanilla `vendor_boot.img`
- Nothing OS 4.1 FeaturePack v2 `boot.img`
- Nothing OS 4.1 OrangeFox v5 `vendor_boot.img`
- KernelSU Next 33252 Manager
- Evolution X delayed eBPF-lockdown module
- optional MediaTek Wi-Fi workaround module
- `SHA256SUMS`

Official restore images, raw device logs, signing private keys and personal
information are intentionally excluded.
