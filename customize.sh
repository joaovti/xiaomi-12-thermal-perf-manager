#!/system/bin/sh
ui_print "****************************************"
ui_print "*   Xiaomi 12 Thermal & Perf Manager   *"
ui_print "*        Snapdragon 8 Gen 1 (cupid)    *"
ui_print "****************************************"

# Remove legacy module if present
if [ -d "/data/adb/modules/perf-limit-xiaomi-12" ]; then
    ui_print "- Removing legacy perf-limit-xiaomi-12 module..."
    touch "/data/adb/modules/perf-limit-xiaomi-12/remove"
fi

ui_print "- Configuring script permissions..."
set_perm "$MODPATH/set_profile.sh" 0 0 0755
set_perm "$MODPATH/get_status.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755

ui_print "- Applying Profile 2 (Cool Performance) as default..."
sh "$MODPATH/set_profile.sh" 2

ui_print "- Installation completed successfully!"
ui_print "- Open the module in KernelSU app to access the WebUI!"
