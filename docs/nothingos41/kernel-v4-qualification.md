# Nothing OS 4.1 FeaturePack kernel v4 qualification

Target: CMF Phone 1 (`Tetris` / A015), Nothing OS 4.1
`B4.1-260812-1726`, slot A. Test date: 2026-09-01.

The installed `boot_a` SHA-256 matched the release image exactly. Android boot,
KernelSU Next 33252 root, matching `ksud`, SUSFS, active BBRv3 and every requested
feature probe passed. The test covered congestion controls, WireGuard, IP Set,
IPv6 NAT, TTL/CONNMARK, CAKE/fq/fq_codel, CIFS, NTSync, tmpfs xattrs/ACLs,
namespaces and BTF/eBPF.

Repeated Android process-map traversal produced no `pgsize_migration.c` or
`vma_pad_pages` warning after the AOSP VMA-split fix. CPU checksum, reversible
F2FS write/read and direct-IP networking stress passed. Bluetooth completed a
clean on/off cycle; camera, location/GNSS and thermal services were healthy.
The final current-boot kernel log and Android crash buffer contained no relevant
fatal event.

Image SHA-256:
`2ef61b55d5202ccb34e477a1aa9913d32495712a8785d4aaef470cc831a12010`
