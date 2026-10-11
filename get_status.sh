#!/system/bin/sh
# Obter status atual do hardware em JSON
P0_CUR=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq 2>/dev/null || echo 0)
P0_MAX=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null || echo 0)

P4_CUR=$(cat /sys/devices/system/cpu/cpufreq/policy4/scaling_cur_freq 2>/dev/null || echo 0)
P4_MAX=$(cat /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq 2>/dev/null || echo 0)

P7_CUR=$(cat /sys/devices/system/cpu/cpufreq/policy7/scaling_cur_freq 2>/dev/null || echo 0)
P7_MAX=$(cat /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq 2>/dev/null || echo 0)

GPU_CUR=$(cat /sys/class/kgsl/kgsl-3d0/gpuclk 2>/dev/null || echo 0)
GPU_LEVEL=$(cat /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null || echo 0)

BAT_TEMP_RAW=$(cat /sys/class/power_supply/battery/temp 2>/dev/null || echo 0)
# Converte 347 para 34.7
BAT_TEMP=$(awk -v t="$BAT_TEMP_RAW" 'BEGIN { printf "%.1f", t / 10 }')

PROFILE=$(cat /data/adb/cupid_perf_profile.txt 2>/dev/null || echo "2")

echo "{\"little_cur\":$P0_CUR,\"little_max\":$P0_MAX,\"big_cur\":$P4_CUR,\"big_max\":$P4_MAX,\"prime_cur\":$P7_CUR,\"prime_max\":$P7_MAX,\"gpu_cur\":$GPU_CUR,\"gpu_level\":$GPU_LEVEL,\"battery_temp\":\"$BAT_TEMP\",\"profile\":\"$PROFILE\"}"
