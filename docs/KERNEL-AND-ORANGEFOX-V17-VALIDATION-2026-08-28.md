# CMF Phone 1 kernel and OrangeFox v17 validation

Date: 2026-08-28

Device: CMF Phone 1 / Tetris, active slot B

## Installed images

- Kernel boot image: `CMF-Phone-1-EvolutionX-11.10-GApps-FeaturePack-WiFiFix-SUExecFix-v4-KSUNext-33252-SUSFS-2.2.0-boot.img`
  - SHA-256: `7b18feeee9c50c100650a61779dd54133debabada6f410710a477f6ec0215098`
- Recovery vendor_boot image: `CMF-Phone-1-EvolutionX-11.10-OrangeFox-R12.0-Android16-StockPlatform-v17-DataFormatFix-vendor_boot.img`
  - SHA-256: `a2a6034671f822c173abe719c5c7d9d69325cbf92e1422ff70b49176a20edb62`
  - The live `vendor_boot_b` partition matched this hash after flashing.

## Kernel results

| Feature | Result | Evidence |
| --- | --- | --- |
| KernelSU Next | Pass | Manager/kernel interface reports version 33252; `su` returned UID 0 in the `u:r:ksu:s0` domain. |
| Installed `ksud` | Pass | `/data/adb/ksud debug version` reports 33252 and its SELinux label is `u:object_r:ksu_file:s0`. No version mismatch remains. |
| SUSFS 2.2.0 | Pass | KSU/SUSFS configuration and symbols are present; SUS path, mount, map, kstat, uname, cmdline and bootconfig options are enabled. |
| Baseband Guard | Loaded | Live LSM order is `capability,selinux,baseband_guard`; BBG symbols and configuration are present. Protected-partition write blocking was not deliberately triggered. |
| Wi-Fi fix | Pass | Wi-Fi 6 connected successfully; a complete disable/enable cycle reconnected automatically, DHCP restored the route, and gateway ping completed with 0% loss. |
| BindHosts | Pass | `/system/etc/hosts` is mounted through BindHosts and contains 756,528 lines. |
| BBR v1 / BBR v3 | Pass | Both are available; BBR3 is the active congestion controller. |
| CUBIC / BIC / Westwood / HTCP | Pass | All are advertised by the running kernel. |
| WireGuard | Pass | A temporary WireGuard interface was created, queried and removed successfully. |
| IP Set | Kernel pass | IP Set and its bitmap/hash/list backends are enabled. Recovery/ROM does not contain an `ipset` userspace command, so a real set was not created. |
| IPv6 NAT | Pass | IPv6 NAT tables and base chains are accessible at runtime. |
| TTL / HL targets | Pass | IPv4 TTL and IPv6 HL targets are registered in the running netfilter stack. |
| connmark / CONNMARK | Pass | Match and target handlers are registered at runtime. |
| CAKE / fq / fq_codel | Pass | Each queue discipline was attached to an unused temporary interface, inspected and removed successfully. |
| CIFS / SMB3 | Kernel pass | CIFS and SMB3 are registered filesystems. No external SMB server was supplied for a remote-mount test. |
| TMPFS_XATTR | Pass | A trusted xattr was written and read on a temporary tmpfs. This is the xattr namespace needed by OverlayFS/Mountify. |
| TMPFS_POSIX_ACL | Pass | A correctly encoded extended POSIX ACL was written and read on tmpfs (`acl_bytes=44`, resulting mode 0755). |
| NTSync | Pass | `/dev/ntsync` exists and the NTSync symbols are live. |
| BTF / eBPF | Pass | `/sys/kernel/btf/vmlinux` exists and bpffs is mounted read/write. BPF events and FUSE-BPF are configured. |
| DroidSpaces prerequisites | Pass | User/PID/network namespaces, cgroup v2, veth, bridge, OverlayFS and seccomp are enabled; transient namespace, veth, bridge and OverlayFS tests passed. |
| Experimental Unicode hardening | Static pass | The hardening change is present in the built source patch. A hostile-path end-to-end test was not performed. |
| Ptrace leak fix | Not applicable | The upstream workaround is for kernels older than 5.16; this kernel is 6.1.134. |

Transient interfaces, mounts, files and test namespaces were removed after testing. The running kernel log contained no panic, Oops, BUG, call trace or unresolved-symbol signature during the audit.

## OrangeFox v17 results

- OrangeFox booted successfully and remained alive during the validation period.
- `/metadata`, `/data` and `/sdcard` are mounted read/write.
- Device-side USB state is `mtp,adb`.
- The final recovery snapshot had about 456 seconds uptime and no kernel panic/Oops/BUG signature.
- Only removable placeholder mount points (`/auto0` through `/auto3` and `/usb_otg`) were unmounted, as expected when no removable media was attached.

## Deliberately untested or partially tested

- **Format Data / encryption removal:** v17 contains the intended fix, but the destructive wipe operation was not executed without a separate explicit confirmation. This is the only way to prove the complete data-format path.
- **Baseband Guard write denial:** no critical partition was used as a write target because doing so could brick or corrupt the phone.
- **Full DroidSpaces container:** kernel prerequisites passed, but a complete Linux distribution was not launched because the DroidSpaces userspace was not installed for this check.
- **CIFS remote mount:** requires credentials and a reachable SMB server.
- **FUSE-BPF application workload:** kernel support is enabled, but no compatible FUSE-BPF userspace workload was available.
- **Host-side MTP browsing:** recovery reports `mtp,adb`; successful browsing still needs confirmation in the desktop file manager.

No user data was wiped during this validation.
