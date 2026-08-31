# OrangeFox R12.0 v5 Qualification Report

Device: CMF Phone 1 (`Tetris` / `A015`)

ROM: Nothing OS 4.1 `B4.1-260812-1726`

Active slot: `a`

Test date: 2026-08-31

Image SHA-256: `7f1c9a86c637511cde57c94b8d6bc9aaf5034f23fcb973e0afa3e00f8b7ef956`

## Passed

- The active `vendor_boot_a` hash exactly matches the packaged v5 image.
- Three clean recovery boots loaded all four charger providers, `bootinfo`,
  `touchpanel_event_notify`, and `focaltech_tp` automatically.
- The FocalTech touchscreen registered as `fts_ts`, accepted PIN input, and
  remained operational after recovery and fastbootd round-trips.
- Nothing OS file-based encryption decrypted user 0 successfully on repeated
  fresh boots. `/data/media/0` and `/sdcard` exposed the real internal files.
- ADB push/pull produced byte-identical files.
- A 64 MiB Boot backup completed successfully. Its image and generated digest
  exactly matched the live `boot_a` partition.
- Three further 64 MiB reads of that backup were byte-identical (192 MiB total).
- Direct installation of a non-destructive no-op ZIP completed successfully.
- The GUI sideload path started, transferred and installed the no-op ZIP, then
  returned to normal recovery ADB without changing the recovery PID.
- The on-screen sideload Cancel action killed mini-ADB, returned to normal ADB,
  reached the completion page, and did not hang or restart recovery.
- MTP started, enumerated as `18d1:4ee2`, exposed `Internal Storage`, and allowed
  the computer to browse and hash the qualification file correctly. OrangeFox's
  stop action then returned USB to ADB-only mode without a crash or
  recovery-process restart.
- Read-only mounts of System, Vendor, Product, and System Ext succeeded. The
  4 KiB all-zero `odm_a` placeholder correctly rejected filesystem mounting.
- Fastbootd entered as userspace fastboot, reported product `Tetris` and slot
  `a`, and returned to recovery successfully.
- Reboot to System reached Android 16 / Nothing OS 4.1 boot completion in 35
  seconds, then returned to OrangeFox successfully.
- Recovery time matched the host clock. Battery capacity/status and thermal
  readings were plausible and stable.
- A five-minute, 21-sample monitor kept the same recovery PID, 7.36 GB available
  memory, 40-41 C temperature, decrypted mounts, ADB, and zero fatal kernel or
  filesystem errors.

## Known issues and limitations

1. **OrangeFox command-line/sideload page race:** starting sideload with
   `adb shell twrp sideload` drops the command output reader when USB changes
   mode. Subsequent output can raise `SIGPIPE`, causing init to restart the
   recovery process. The genuine on-screen sideload path passed.
2. A timed-out or overlapping OrangeFox command-line request can call the ORS
   completion callback twice and abort on `fclose(NULL)`. This was reproduced
   only through the diagnostic command channel.
3. Running another `twrp` CLI command while the UI still considers the sideload
   action page current can return to that page and retrigger sideload. Navigate
   away from the sideload completion page before using the CLI.
4. The remote diagnostic MTP stop sequence completed and restored ADB-only USB,
   but left the UI on the generic single-action loading page until
   `twrp changepage=main` was issued. The recovery process itself stayed healthy.
   This was produced by the command-line qualification path; the normal physical
   MTP toggle should be treated as not fully qualified.
5. Recovery logs repeatedly probe optional MediaTek/Nothing mount paths such as
   `protect_f`, `protect_s`, `nvdata`, `nvcfg`, `persist`, and `nt_log` that are
   not exposed as OrangeFox partitions. This is noisy but did not affect the
   tested mounts or Android boot.
6. The legacy timed-output vibrator path is absent, so recovery haptic feedback
   may not work even though touch input works.
7. USB OTG and removable storage were not tested because no corresponding
   peripheral was connected.

## Not executed to protect user data and installed partitions

- Restore to a live partition
- Wipe or Format Data
- ROM installation or image flashing
- Active-slot changes

These operations are destructive or partition-writing and require a separate,
explicit test authorization and a verified backup/restore plan.

## Test artifacts

- `qualification-final-recovery.log` is the final clean-boot recovery log.
- `qualification-mtp-cycle-recovery.log` records the successful MTP start/stop
  cycle and the return to ADB-only mode.
- `qualification-noop-sideload.zip` is the harmless package used for direct
  install and sideload testing.
- Temporary files and the 64 MiB test backup were removed from the phone after
  successful verification.
