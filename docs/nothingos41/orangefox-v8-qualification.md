# Nothing OS 4.1 OrangeFox R12.0 v8 qualification

Target: CMF Phone 1 (`Tetris` / A015), Nothing OS 4.1
`B4.1-260812-1726`, slot A. Test date: 2026-09-01.

The installed `vendor_boot_a` SHA-256 matched the v8 release image exactly.
OrangeFox booted its GUI, touch exposed the full panel coordinate range, and
Nothing OS FBE decrypted `/data` and internal storage.

MTP exposed Internal Storage and completed a PC-to-phone-to-PC test transfer
with identical checksums. Two consecutive harmless ADB sideload cycles returned
to normal recovery ADB without changing recovery PIDs, restarting init or
leaving stale sideload state. Post-sideload `system_root` mounting passed. VINTF
manifests parsed, Health AIDL v2 ran, and time/battery values were correct.

After sideload, USB intentionally returns in ADB-only mode. Re-enable MTP from
Mount if needed. v7 is withdrawn because its invalid VINTF overlay could stop at
the CMF logo.

Image SHA-256:
`a4abb8601c56dd7a3c5e6309d9ff5e4bb9ed068a62ffce3c1089ed64e33dbf28`
