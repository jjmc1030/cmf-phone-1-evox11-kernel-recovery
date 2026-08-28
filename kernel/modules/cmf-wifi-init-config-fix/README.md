# CMF Phone 1 MediaTek Wi-Fi Init Config Fix

This KernelSU module preserves the stock CMF Phone 1 `wifi.cfg` and adds two
supported startup configuration entries for the MediaTek driver:

    DbgLevel0 11 0x0f
    DbgLevel1 1 0x0f

The mask keeps ERROR, WARN, STATE, and EVENT logging while suppressing TRACE,
INFO, LOUD, and temporary telemetry for the SW4 and HAL modules. It is designed
to remove the repeated packet-statistics log flood without changing Wi-Fi
behavior or replacing the driver binary. The wrapped NAPI number is a
diagnostic display defect; this suppresses that INFO message but does not alter
the driver's internal counter arithmetic.

The module bind-mounts the modified configuration during KernelSU's early
`post-fs-data` stage, before Android starts Wi-Fi. The stock vendor file remains
unchanged and returns after disabling the module and rebooting.

Reboot once after installing. Then inspect `status.log` in the module directory.
A correct boot contains both `MOUNTED` and `ACTIVE` lines.

The exact early bind mount and content checks passed on the connected phone and
restored the original vendor file after unmount. Startup application by the
driver still requires one reboot and has not yet been boot-tested.

Test target: Evolution X 11.10 (Android 16), kernel
`6.1.134-android14-11 #4`, KernelSU Next 33252, and the stock CMF Phone 1
MediaTek `wlan_drv_gen4m_6878.ko`.

## Credits and sources

- KernelSU Next module system: https://github.com/KernelSU-Next/KernelSU-Next
- MediaTek WLAN configuration behavior:
  https://android.googlesource.com/kernel/mediatek/
