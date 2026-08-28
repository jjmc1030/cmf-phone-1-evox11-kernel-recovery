# CMF Phone 1 kernel for Evolution X 11.10

This package contains a custom GKI kernel for the CMF Phone 1 (`Tetris`) with:

- KernelSU Next v3.3.0, kernel version `33229`
- SUSFS v2.2.0 with all supplied features enabled
- Kernel release `6.1.134-android14-11`
- The ABI/KMI expected by the Evolution X 11.10 `Tetris` kernel package

## Files

- `CMF-Phone-1-EvolutionX-11.10-GApps-KSUNext-33229-SUSFS-2.2.0-boot.img`: complete, AVB-signed boot image for the 2026-08-19 **GApps** build.
- `CMF-Phone-1-EvolutionX-11.10-Vanilla-KSUNext-33229-SUSFS-2.2.0-boot.img`: complete, AVB-signed boot image for the 2026-08-19 **Vanilla** build.
- `CMF-Phone-1-EvolutionX-11.10-GApps-OFFICIAL-RESTORE-boot.img`: unmodified official GApps boot image for recovery.
- `CMF-Phone-1-EvolutionX-11.10-Vanilla-OFFICIAL-RESTORE-boot.img`: unmodified official Vanilla boot image for recovery.
- `flash-gapps-boot.sh`: guarded Linux fastboot script for the GApps image; it validates the checksum, device, unlocked state, and active slot before asking for confirmation.
- `CMF-Phone-1-EvolutionX-11.10-KSUNext-33229-SUSFS-2.2.0-AnyKernel3.zip`: recovery or root-kernel-flasher package.
- `CMF-Phone-1-EvolutionX-11.10-KSUNext-33229-SUSFS-2.2.0-Image.lz4`: compressed kernel only. Do not flash this raw file to `boot`.
- `CMF-Phone-1-EvolutionX-11.10-KSUNext-SUSFS-source.patch`: all kernel-side changes.
- `build-cmf-evox-kernel.sh`: pinned rebuild script.
- `SHA256SUMS`: integrity hashes.

## Compatibility and validation

The base is Android Common Kernel tag `android14-6.1-2025-05_r1`, commit `8dc7d7757edd922ed1e79851711dc2c47bfcf227`. That is the exact source fingerprint embedded in Evolution X's shipped kernel.

The build was checked against all 481 kernel modules shipped in the current Evolution X `device_nothing_Tetris-kernel` `bka` branch. The 3,147 shared imported/exported GKI symbols had zero CRC mismatches. The kernel and module vermagic are both exactly `6.1.134-android14-11 SMP preempt mod_unload modversions aarch64`.

Both complete boot images preserve the official header-v4 settings (`Android 16.0.0`, `2026-08` patch level, 4096-byte page size, empty boot ramdisk) and the exact GApps/Vanilla build fingerprint. Their AVB footers were regenerated with the same AOSP RSA-2048 test key used by the official Evolution X images. Full AVB signature and boot-payload hash verification passed for both editions, and unpacking each image reproduced the custom kernel exactly.

The kernel compiled successfully, but it has not been boot-tested on a physical CMF Phone 1 because no device was connected during the build.

## Before flashing

1. Confirm the phone is the CMF Phone 1 (`Tetris`) and the ROM's current kernel reports `6.1.134-android14-11`.
2. The bootloader must already be unlocked. Unlocking wipes user data.
3. Keep the matching official restore image from this folder and a known-working fastboot environment.
4. Remove or restore other kernel-root methods first. In particular, do not leave Magisk/APatch in `init_boot` while testing KernelSU Next.
5. Keep the matching KernelSU Next v3.3.0 manager APK ready. The kernel accepts both the official KernelSU Next manager signature and the pinned SUSFS fork manager signature.

## Flashing

The CMF Phone 1 stores the kernel in `boot`; `init_boot` contains the first-stage ramdisk. **Never flash these files to `init_boot_a` or `init_boot_b`.** Stock recovery cannot install an arbitrary boot image, so use bootloader fastboot.

For the GApps build on Linux, place the phone in bootloader mode and run `./flash-gapps-boot.sh`. The script performs the checks and active-slot flashing below automatically.

1. Choose the GApps or Vanilla custom image matching the ROM edition currently installed.
2. Reboot to the bootloader and connect USB. Confirm the connection with `fastboot devices`.
3. Check the active slot with `fastboot getvar current-slot`.
4. If the result is `a`, run `fastboot flash boot_a <matching-custom-boot.img>`. If it is `b`, run `fastboot flash boot_b <matching-custom-boot.img>`.
5. Run `fastboot reboot`.

Some bootloaders support a non-persistent test with `fastboot boot <matching-custom-boot.img>` before step 4. If Tetris reports that this command is unsupported, return to the explicit active-slot flashing instructions above.

The AnyKernel3 ZIP remains available for a compatible custom recovery or a trusted root kernel-flasher app. It checks for device name `Tetris`/`tetris` and patches the active A/B `boot` slot.

Do not run `fastboot flash boot ...Image.lz4`; the standalone file is a kernel payload, not a complete Android boot image.

After the first successful boot, install/open KernelSU Next manager v3.3.0. SUSFS is present in the kernel, but SUSFS policies and hiding behavior require a compatible userspace SUSFS module/tool.

If the device bootloops, return to the bootloader and flash the matching `OFFICIAL-RESTORE-boot.img` to the same slot. Do not erase data as a first recovery step.

## Rebuilding

Run `build-cmf-evox-kernel.sh` on Linux with Git, Make, LZ4, Flex, Bison, BC, OpenSSL, Perl, Pahole, and Rsync installed. Without `CLANG_DIR`, the script downloads the pinned AOSP Clang checkout, which occupies roughly 18 GB. Set `CLANG_DIR` to an existing AOSP Clang `clang-r487747b` directory to reuse one.

The KernelSU Next/SUSFS driver is pinned to commit `26fded805206ae4542f4745e09cc465412994492`; this is the v3.3.0/33229 combination used for the build. The upstream SUSFS kernel source is v2.2.0 from the `gki-android14-6.1` line, commit `0ff932799d898366d57b3b5984d85cdbcfcfad0a`.
