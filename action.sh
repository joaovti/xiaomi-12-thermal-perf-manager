#!/system/bin/sh
MODDIR=${0%/*}
CONF_FILE="/data/adb/cupid_perf_profile.txt"

CUR="1"
[ -f "$CONF_FILE" ] && CUR=$(cat "$CONF_FILE")

case "$CUR" in
    1) NEXT="2" ;;
    2) NEXT="0" ;;
    *) NEXT="1" ;;
esac

sh "$MODDIR/set_profile.sh" "$NEXT"
