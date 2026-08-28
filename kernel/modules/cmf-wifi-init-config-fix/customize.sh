#!/system/bin/sh

ui_print "- Installing CMF Phone 1 Wi-Fi init configuration fix"
ui_print "- The stock file is preserved; the override is systemless"
ui_print "- Reboot once after installation"

set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/wifi.cfg" 0 0 0644
