# Recovery patch order

Pinned bases are listed in the top-level `CREDITS.md`. Apply each patch from
the root of the repository named below.

1. `orangefox16-r12-vendor.patch` → `vendor/recovery`
2. Reassemble `orangefox16-r12-ui-port.patch`, then apply it to
   `bootable/recovery`
3. `orangefox16-r12-v15-runtime.patch` → `bootable/recovery`
4. `orangefox16-r12-v16-format-data-wipe.patch` → `bootable/recovery`
5. `orangefox16-r12-v17-data-format-mapping.patch` → `bootable/recovery`
6. `android16-health-vintf-v15.patch` → `hardware/interfaces`
7. `android16-keystore-kmsg-v15.patch` → `system/security`
8. `orangefox16-r12-v18-v28-and-nothingos41-v5.patch` → `bootable/recovery`
9. `orangefox16-r12-nothingos41-v8-sigpipe.patch` → `bootable/recovery`
10. Place `recovery/device/nothing/Tetris` at `device/nothing/Tetris`, then
   provide only the legally obtained inputs described by its
   `EXCLUDED_INPUTS.md`.

The compressed R12 UI patch is split twice to keep individual Git objects
small. Reassemble it in lexical order:

```bash
cd recovery/patches
cat orangefox16-r12-ui-port.patch.xz.part-*.chunk-* > /tmp/orangefox16-r12-ui-port.patch.xz
xz -dc /tmp/orangefox16-r12-ui-port.patch.xz > /tmp/orangefox16-r12-ui-port.patch
```

Verify before applying:

```bash
git -C /path/to/bootable/recovery apply --check /tmp/orangefox16-r12-ui-port.patch
git -C /path/to/bootable/recovery apply --check recovery/patches/orangefox16-r12-v15-runtime.patch
git -C /path/to/bootable/recovery apply --check recovery/patches/orangefox16-r12-v16-format-data-wipe.patch
git -C /path/to/bootable/recovery apply --check recovery/patches/orangefox16-r12-v17-data-format-mapping.patch
git -C /path/to/bootable/recovery apply --check recovery/patches/orangefox16-r12-v18-v28-and-nothingos41-v5.patch
git -C /path/to/bootable/recovery apply --check recovery/patches/orangefox16-r12-nothingos41-v8-sigpipe.patch
```

The final full `vendor_boot` cannot be generated safely from recovery source
alone. It must retain the target ROM's platform ramdisk, early modules, DTB,
bootconfig and AVB properties. Evolution X and Nothing OS require separate
ROM-matched merges. Nothing OS v8 additionally selects its VINTF overlay from
`device/nothing/Tetris/nothingos41`.
