# Licensing notice

This repository combines patches, configuration, scripts, device-tree files,
and documentation derived from multiple upstream projects. It therefore does
not use one blanket license for every file.

- Linux kernel-derived patches and configuration remain subject to the Linux
  kernel's GPL-2.0-only terms and per-file SPDX identifiers.
- Baseband Guard is distributed under GPL-2.0.
- KernelSU Next, SUSFS4KSU, DroidSpaces-OSS, and OrangeFox components are
  distributed under their respective GPL-3.0-family terms and notices.
- AnyKernel3 material remains under the AnyKernel3 redistribution license.
- Android/AOSP and device-tree components retain their upstream per-file
  notices, licenses, and copyright ownership.
- Raw ROM-derived kernel/DTB/DTBO build inputs, restore images, device backups,
  signing private keys, logs, and source files explicitly marked confidential
  by MediaTek are excluded from Git history. Flashable release images may
  necessarily contain ROM-matched boot components; those components remain
  subject to their original copyright and redistribution terms.
- Original project documentation and small helper-script changes may be reused
  under GPL-3.0-or-later, without changing the licensing of embedded or derived
  upstream material.

Copies of the principal upstream license texts are stored in
`third_party_licenses/`. When a file contains its own SPDX identifier or notice,
that file-specific notice takes precedence.

No trademark rights are granted. CMF, Nothing, Evolution X, KernelSU,
OrangeFox, and TWRP names belong to their respective owners.

The locally signed KernelSU Manager release does not include its private signing
key. The APK remains derived from KernelSU Next and is distributed under that
project's license; the added local certificate does not change the source license.
