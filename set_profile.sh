#!/system/bin/sh
# Xiaomi 12 (cupid) Profile Switcher
PROFILE="$1"
CONF_FILE="/data/adb/cupid_perf_profile.txt"

if [ -z "$PROFILE" ]; then
    if [ -f "$CONF_FILE" ]; then
        PROFILE=$(cat "$CONF_FILE")
    else
        PROFILE="2"
    fi
fi

# Unlock permissions for writing
chmod 644 /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null
chmod 644 /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq 2>/dev/null
chmod 644 /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq 2>/dev/null
chmod 644 /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null

case "$PROFILE" in
    1|"cold"|"eco")
        # Profile 1: Extreme Cold / Battery Saver
        P0_MAX=1075200  # Little (Cortex-A510) 1.07 GHz
        P4_MAX=1881600  # Big (Cortex-A710) 1.88 GHz
        P7_MAX=1728000  # Prime (Cortex-X2) 1.72 GHz
        GPU_MAX=8       # GPU Power Level 8 (~421 MHz)
        LABEL="Extreme Cold (Eco)"
        PROFILE="1"
        ;;
    2|"optimized"|"undervolt")
        # Profile 2: Cool Performance (Undervolt / Sweet Spot)
        P0_MAX=1267200  # Little 1.26 GHz
        P4_MAX=2112000  # Big 2.11 GHz
        P7_MAX=2284800  # Prime 2.28 GHz
        GPU_MAX=6       # GPU Power Level 6 (~599 MHz)
        LABEL="Cool Performance (Undervolt)"
        PROFILE="2"
        ;;
    3|"gaming")
        # Profile 3: Gaming Mode / High Thermal Performance
        P0_MAX=1478400  # Little 1.47 GHz
        P4_MAX=2342400  # Big 2.34 GHz
        P7_MAX=2515200  # Prime 2.51 GHz
        GPU_MAX=4       # GPU Power Level 4 (~640 MHz)
        LABEL="Gaming Mode"
        PROFILE="3"
        ;;
    0|"stock"|"perf")
        # Profile 0: Maximum Power (Factory Stock)
        P0_MAX=1785600  # Little 1.78 GHz
        P4_MAX=2419200  # Big 2.42 GHz
        P7_MAX=2841600  # Prime 2.84 GHz
        GPU_MAX=0       # GPU Unrestricted (818 MHz)
        LABEL="Maximum Power (Stock)"
        PROFILE="0"
        ;;
    *)
        PROFILE="2"
        P0_MAX=1267200
        P4_MAX=2112000
        P7_MAX=2284800
        GPU_MAX=6
        LABEL="Cool Performance (Undervolt)"
        ;;
esac

# Apply frequencies
echo "$P0_MAX" > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null
echo "$P4_MAX" > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq 2>/dev/null
echo "$P7_MAX" > /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq 2>/dev/null
echo "$GPU_MAX" > /sys/class/kgsl/kgsl-3d0/max_pwrlevel 2>/dev/null

# Lock nodes to read-only to prevent thermal-engine overrides
chmod 444 /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null
chmod 444 /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq 2>/dev/null
chmod 444 /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq 2>/dev/null

# Save active profile for reboot persistence
echo "$PROFILE" > "$CONF_FILE"
echo "Profile applied: $LABEL (P0: $P0_MAX, P4: $P4_MAX, P7: $P7_MAX, GPU: $GPU_MAX)"
