#!/bin/bash
# 4600H Full Unlock Script (BIOS TDP 54W)
# Applies: governor=performance, PPT=54W, CO=-20

echo "[4600H] Applying performance settings..."

# 1. Governor (needs root)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
echo "[4600H] Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"

# 2. Load ryzen_smu if not loaded
if ! lsmod | grep -q ryzen_smu; then
    sudo modprobe ryzen_smu
    echo "[4600H] ryzen_smu loaded"
fi

# 3. Apply ryzenadj (needs root)
sudo ryzenadj \
  --stapm-limit=54000 \
  --fast-limit=54000 \
  --slow-limit=54000 \
  --apu-slow-limit=54000 \
  --tctl-temp=95 \
  --vrm-current=58000 \
  --vrmsoc-current=15000 \
  --vrmmax-current=96000 \
  --vrmsocmax-current=20000 \
  --set-coall=-25

echo "[4600H] Done. PPT=54W, CO=-20, Governor=performance"
