# Xiaomi 12 Thermal & Performance Manager

A native KernelSU and APatch module for the Xiaomi 12 (codename: cupid, Snapdragon 8 Gen 1 / SM8450) designed to mitigate overheating, eliminate thermal throttling, and provide real-time hardware monitoring via an interactive WebUI.

---

## Prerequisites

Before installing this module, ensure your environment meets the following requirements:

* Device: Xiaomi 12 (Codename: cupid) powered by Qualcomm Snapdragon 8 Gen 1 (SM8450 / Waipio).
* Root Solution: KernelSU (v0.9.0 or newer), KernelSU-Next, or APatch with module WebUI capability enabled.
* Operating System: Android 12, Android 13, Android 14, Android 15, or Android 17 (tested on LineageOS 24).
* Kernel: Linux Kernel 5.10 GKI (stock or custom) with root privileges granted to the manager application.
* Storage: Standard access to `/data/adb/modules`.

---

## Overview and Problem Statement

The Qualcomm Snapdragon 8 Gen 1 is manufactured on Samsung's 4nm process node and features an aggressive Cortex-X2 Prime core that consumes excessive power at frequencies above 2.3 GHz. Under factory parameters:

1. The Cortex-X2 core operates at up to 2.84 GHz at 1.12V - 1.15V, creating rapid thermal spikes.
2. The stock thermal daemon (`thermal-engine` / `mi_thermald`) triggers aggressive thermal throttling, dropping CPU and GPU clocks abruptly to lower states, causing noticeable frame drops and high battery temperatures (>45 deg C).
3. Traditional Magisk modules frequently fail to maintain frequency caps because system daemons overwrite `/sys/devices/system/cpu/cpufreq/policy*/scaling_max_freq`.

This module solves these issues by:
* Capping frequencies at peak energy-efficiency points ("sweet spots") where voltage drops by up to 250mV while retaining 90%+ of peak IPC.
* Locking frequency sysfs nodes to read-only (`chmod 444`) to permanently prevent background daemon overrides.
* Providing an interactive WebUI inside KernelSU for instant profile switching without reboots.
* Exposing real-time CPU and GPU clocks along with battery temperature sensors.

---

## Thermal Profiles

The module includes four switchable profiles:

| Profile | Profile ID | Little (A510) Cap | Big (A710) Cap | Prime (X2) Cap | GPU Max Level | Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Cool Performance (Recommended) | 2 | 1.26 GHz | 2.11 GHz | 2.28 GHz | Level 6 (~599 MHz) | Optimal undervolt point. Voltage drops from 1.12V to ~0.88V, reducing thermal output by ~50% with negligible performance difference. |
| Extreme Cold (Battery Saver) | 1 | 1.07 GHz | 1.88 GHz | 1.72 GHz | Level 8 (~421 MHz) | Maximum energy efficiency. Keeps battery temperatures below 36 deg C under continuous daily usage. |
| Gaming Mode | 3 | 1.47 GHz | 2.34 GHz | 2.51 GHz | Level 4 (~640 MHz) | Balanced gaming profile ensuring constant 60/120 FPS without thermal throttling. |
| Maximum Power (Stock) | 0 | 1.78 GHz | 2.41 GHz | 2.84 GHz | Level 0 (818 MHz) | 100% factory parameters without restrictions. |

---

## Repository Structure and Code Breakdown

```
cupid-perf-manager/
├── META-INF/
│   └── com/google/android/
│       ├── update-binary       # Standard Magisk/KernelSU installer bootstrap
│       └── updater-script      # Dummy updater script
├── webroot/
│   └── index.html              # Interactive WebUI dashboard (HTML, CSS, JS)
├── action.sh                   # Physical/app action button script to cycle profiles
├── customize.sh                # Installation script configuring permissions and defaults
├── get_status.sh               # Real-time hardware telemetry exporter (single-line JSON)
├── module.prop                 # Module metadata (ID, version, description)
├── service.sh                  # Boot service applying the saved profile after system init
└── set_profile.sh              # Core frequency and power-level control engine
```

### Script Details

* `set_profile.sh`: Unlocks the CPU `scaling_max_freq` sysfs nodes (`chmod 644`), applies the target frequency values for cluster 0 (Little), cluster 4 (Big), and cluster 7 (Prime), caps the GPU power level via `/sys/class/kgsl/kgsl-3d0/max_pwrlevel`, and relocks the sysfs nodes to read-only (`chmod 444`) to prevent system thermal daemons from overriding values. It persists the current selection in `/data/adb/cupid_perf_profile.txt`.
* `get_status.sh`: Collects live hardware status (current and maximum frequencies of all 3 CPU clusters, GPU frequency, active power level, battery temperature, and active profile) and prints the result as a single-line JSON string to ensure compatibility with KernelSU's synchronous `ksu.exec` bridge.
* `service.sh`: Executes during boot (`late_start` service). Waits until `sys.boot_completed` equals 1, allows governor initialization to settle, and reapplies the stored profile.
* `customize.sh`: Runs during installation. Verifies permissions, removes legacy modules if detected, sets executable permissions on all shell scripts, and activates Profile 2 (Cool Performance) by default.
* `webroot/index.html`: Web-based dashboard rendered inside the KernelSU Manager. Uses `window.ksu` to periodically read hardware sensors and trigger profile changes on click.

---

## Installation

1. Download `Xiaomi-12-Thermal-Perf-Manager-v1.0.zip` from the Releases section.
2. Open KernelSU, KernelSU-Next, or APatch on your Xiaomi 12.
3. Navigate to the Modules section and select "Install".
4. Select the downloaded `.zip` file.
5. Once installation finishes, restart your device or open the module WebUI directly to start using it.

---

## CLI Usage

You can also manage profiles directly from a root terminal or ADB shell without opening the WebUI:

```bash
# Apply Profile 2 (Cool Performance / Undervolt)
su -c "sh /data/adb/modules/cupid-perf-manager/set_profile.sh 2"

# Apply Profile 1 (Extreme Cold / Battery Saver)
su -c "sh /data/adb/modules/cupid-perf-manager/set_profile.sh 1"

# Apply Profile 3 (Gaming Mode)
su -c "sh /data/adb/modules/cupid-perf-manager/set_profile.sh 3"

# Restore Stock Frequencies
su -c "sh /data/adb/modules/cupid-perf-manager/set_profile.sh 0"

# Check Live Hardware Status in JSON
su -c "sh /data/adb/modules/cupid-perf-manager/get_status.sh"
```

---

## License

This project is released under the MIT License.
