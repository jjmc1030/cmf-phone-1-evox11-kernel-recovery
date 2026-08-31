# CMF Phone 1 Android 16 kernel and OrangeFox R12

Experimental, unofficial kernel and recovery builds for CMF Phone 1
(`Tetris` / A015), created with assistance from OpenAI Codex.

> [!CAUTION]
> These are device- and ROM-build-specific low-level images. An unlocked
> bootloader is required. Keep exact ROM-matched `boot` and `vendor_boot`
> restore images, verify SHA-256 checksums and flash only the active slot. The
> project author, contributors, upstream projects, OpenAI and OpenAI Codex are
> not responsible for broken devices, bootloops or lost data.

## v2.0.0 tested matrix

| ROM target | Kernel | OrangeFox | Result |
| --- | --- | --- | --- |
| Evolution X 11.10 GApps build 2447 | FeaturePack v5, 6.1.134 | R12 v28 GApps | ROM-specific package; GApps build uses its own AVB metadata and platform image |
| Evolution X 11.10 Vanilla build 2446 | FeaturePack v5, 6.1.134 | R12 v28 Vanilla | Both images live-tested together |
| Nothing OS 4.1 `B4.1-260812-1726` | FeaturePack v2, 6.1.162 | R12 v5 | Both images live-tested on the exact stock build |

Do not interchange GApps, Vanilla or Nothing OS images. Nothing OS uses a
different GKI base and stock module-signing trust chain. Each OrangeFox image
also preserves the target ROM's own platform ramdisk, DTB and bootconfig.

## Kernel features

- KernelSU Next 33252 with matching Manager and `ksud`
- SUSFS 2.2.0
- Baseband Guard
- DroidSpaces/LXC-oriented namespace prerequisites
- BBRv1 and BBRv3, CUBIC, BIC, Westwood and HTCP
- WireGuard, IP Set, IPv6 NAT, TTL/HL and CONNMARK
- CAKE, fq and fq_codel
- CIFS, NTSync, tmpfs xattrs and POSIX ACLs
- BTF/eBPF, BPF events and FUSE-BPF

Evolution X v5 defaults unprivileged BPF off early but lets the ROM finish its
startup policy. The optional post-boot module applies a delayed lockdown after
Android finishes booting. The rejected v6 hard-lock implementation bootlooped
and is not distributed.

Nothing OS v2 embeds only the public certificate from the exact stock kernel so
the official Bluetooth/Wi-Fi modules retain access to protected GKI exports. No
private signing key is included.

## OrangeFox status

Evolution X v28 includes the accumulated data-format, ROM ZIP, safe recovery
reflash, A/B payload, FBE/internal storage, MTP, clock, battery and sideload
fixes. Vanilla v28 passed decryption, internal-storage MTP round-trip and a
non-destructive sideload without the previous finishing/cancel hang.

Nothing OS v5 passed touch, PIN/FBE decryption, internal storage, boot backup
integrity, direct ZIP installation, on-screen sideload/cancel, MTP service
transitions, fastbootd, Android reboot and a five-minute stability monitor. Its
remote command-line MTP action can leave the UI on a single-action loading page;
normal recovery navigation restores the UI. The OrangeFox CLI/ORS sideload
diagnostic path also has an output-pipe race, so use the on-screen sideload UI.

## Repository layout

- `kernel/config`, `kernel/patches`, `kernel/scripts` — final configurations,
  integration patches and pinned build/package scripts.
- `recovery/device/nothing/Tetris` — Android 16 device tree with separate
  Evolution X and Nothing OS products.
- `recovery/patches`, `recovery/scripts` — OrangeFox R12 changes and packaging
  helpers through Evolution X v28 / Nothing OS v5.
- `docs` — live validation and compatibility records.
- `CREDITS.md`, `LICENSES.md` — upstream acknowledgements and licensing.

The complete Evolution X kernel source is on `main` in
[`cmf-phone-1-evox11-kernel-source`](https://github.com/jjmc1030/cmf-phone-1-evox11-kernel-source).
The exact Nothing OS 4.1 / Linux 6.1.162 source is published in that repository's
`nothingos-4.1-b4.1-260812-1726` branch.

## Installation

Download only the pair matching the exact installed ROM. In bootloader fastboot
(not fastbootd), inspect the active slot:

```text
fastboot getvar current-slot
```

Replace `<slot>` with exactly `a` or `b`:

```text
fastboot flash boot_<slot> ROM-MATCHED-CUSTOM-boot.img
fastboot flash vendor_boot_<slot> ROM-MATCHED-OrangeFox-vendor_boot.img
fastboot reboot
```

You may flash only one component. Never flash a kernel to `init_boot` or
`vendor_boot`, and never flash the recovery image to `boot`, `init_boot` or a
standalone `recovery` partition.

Official stock/ROM restore images are intentionally not redistributed. If a
component fails, return to bootloader fastboot and restore the matching original
image to the same active partition before considering a data wipe.

See [COMPATIBILITY.md](COMPATIBILITY.md), [RELEASE_NOTES.md](RELEASE_NOTES.md)
and the GitHub release checksums before flashing.
