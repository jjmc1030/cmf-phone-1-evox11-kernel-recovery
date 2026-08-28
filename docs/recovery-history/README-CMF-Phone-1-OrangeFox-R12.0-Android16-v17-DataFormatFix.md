# OrangeFox R12.0 Android 16 stock-platform v17 data-format fix

Target: CMF Phone 1 (`Tetris` / A015) on the tested Evolution X 11.10 GApps
Android 16 firmware.

## Failure diagnosed from the connected phone

OrangeFox v16 passed its Virtual A/B snapshot check and unmounted `/data`, but
`make_f2fs` still stopped before formatting the physical userdata partition:

```text
Error: In use by the system!
Unable to wipe Data.
Unable to format to remove encryption.
```

The phone's `userdata` metadata-encryption mapping (`/dev/block/mapper/userdata`)
was still holding the physical userdata block device. The recovery-only
Trustonic `mcDriverDaemon` also retained open secure-storage files under
`/data/vendor/mcRegistry`, so a lazy unmount did not release the mapping.

This also explains why a factory reset requested from Android Settings could
return to the old lock screen: the request entered custom recovery, but the
userdata format failed and the encrypted data remained intact.

## v17 fix

After the user confirms Format Data and the Virtual A/B pre-wipe safety check
passes, OrangeFox now:

1. stops the recovery-only Keystore2 and Trustonic crypto stack;
2. waits for those services to release their userdata files;
3. unmounts `/data`;
4. removes the metadata-encryption `userdata` device-mapper mapping through
   Android's native device-mapper API; and
5. invokes `make_f2fs` on the physical userdata partition.

If the crypto services or mapping cannot be released, v17 refuses to format
instead of issuing `mkfs` against a busy block device. The v16 Virtual A/B
snapshot safety fix is retained.

## Verification

- The Android 16 OrangeFox recovery binary compiled successfully.
- The compiled binary contains the service-stop, device-mapper teardown, and
  Virtual A/B safety paths.
- The Evolution X platform ramdisk, DTB, and bootconfig are byte-for-byte
  identical to the tested v16 image.
- The final 64 MiB image has a valid SHA256_RSA2048 AVB footer using the same
  test key and Evolution X vendor-boot fingerprint as v16.
- No automatic Format Data test was performed because it irreversibly erases
  the phone.

Component SHA-256 values:

- Evolution X platform ramdisk:
  `87972876c52eee7ffdd9b70f60d1ec8065823a374742fa48fbc7ec033e213bdc`
- OrangeFox v17 recovery ramdisk:
  `6fb382a42a46539c6c2936165a9c4cdf1b0bd0620d349559078f166d351a7d73`
- DTB:
  `c8b0ec24d4573c03706717d02520f1f7438d7764466a8918a54052039748da35`
- bootconfig:
  `dca836574abf9269802b032b8be5a32838705586a49d348d1c396c2f7bd56219`

## Compatibility warning

This complete `vendor_boot` image is specific to the tested Evolution X 11.10
platform. Do not flash it directly over stock Nothing OS or another custom ROM.
Those ROMs require their own platform ramdisk, DTB, bootconfig, and AVB metadata.

## Checksums

```text
a2a6034671f822c173abe719c5c7d9d69325cbf92e1422ff70b49176a20edb62  CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-StockPlatform-v17-DataFormatFix-vendor_boot.img
592d64c8e65fe2a73a37c5cfb453fced27062f5753d136e228c9b80526c05779  CMF-Phone-1-EvolutionX-11.10-OFFICIAL-RESTORE-vendor_boot.img
```
