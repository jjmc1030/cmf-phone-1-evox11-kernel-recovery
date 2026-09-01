# CMF Phone 1 — Nothing OS 4.1 qualified stable final release

Stable designation is limited to CMF Phone 1 (`Tetris` / A015) running the exact
Nothing OS 4.1 build `B4.1-260812-1726`.

## Included

- FeaturePack kernel v4, Linux `6.1.162-android14-11`
- KernelSU Next 33252 with matching `ksud`
- SUSFS 2.2.0 and Baseband Guard
- Complete networking/filesystem/NTSync/BTF/eBPF feature pack
- OrangeFox R12.0 v8 `vendor_boot`

## Kernel v4 fixes and validation

- Preserves the exact stock module ABI and Nothing OS module trust chain.
- Fixes dynamic Shadow Call Stack and Android NTSync integration.
- Fixes duplicate vendor trace-hook registration.
- Includes both Android 16K page-size migration fixes, including AOSP's VMA
  split correction `f6729da2b825ae9e229dea9b3dffafb72b9051eb`.
- Passed all feature probes, VMA regression testing, CPU/F2FS/network stress,
  Wi-Fi/Bluetooth, camera/location/thermal service checks, KernelSU root and a
  clean final kernel/Android crash-log audit.

## OrangeFox v8 fixes and validation

- Corrects the vendor VINTF overlay and Health AIDL v2 declaration.
- Fixes the sideload SIGPIPE/recovery restart path and bounds minadbd teardown.
- Passed GUI boot, touch, Nothing OS FBE decryption, internal storage, real
  bidirectional MTP transfer, two consecutive harmless sideload cycles and
  post-sideload mounting.
- v7 is withdrawn and must not be flashed.

After sideload, v8 deliberately returns to ADB-only mode to avoid the historical
finish/cancel deadlock. Re-enable MTP from OrangeFox's Mount page if required.

## Final release and community handover

This is the final planned release from the current maintainer. This was a side
project, and there is no longer enough time to continue regular development.
The source and reproducible patches are public in the hope that the CMF Phone 1
community will take over OrangeFox maintenance and, if possible, continue the
kernel project. Thank you to everyone who tested, contributed and helped debug
the builds.

## Safety

Do not flash these images on another Nothing OS build, Evolution X, another ROM
or another device. Verify SHA-256 and the active slot before flashing. Keep the
original `boot` and `vendor_boot` images from this exact build available.

The author, contributors, upstream projects, OpenAI and OpenAI Codex are not
responsible for broken devices, bootloops or lost data.

## Source and credits

- Release and recovery sources: <https://github.com/jjmc1030/cmf-phone-1-evox11-kernel-recovery>
- Complete kernel source: <https://github.com/jjmc1030/cmf-phone-1-evox11-kernel-source/tree/nothingos-4.1-b4.1-260812-1726>

Credits belong to Android common-kernel and Linux contributors, KernelSU Next,
SUSFS4KSU/Simon Punk, pershoot, Baseband Guard, WildKernels, DroidSpaces-OSS,
OrangeFox, TeamWin, NothingOSS and their contributors. Integration, build,
debugging and validation were performed with assistance from OpenAI Codex.
