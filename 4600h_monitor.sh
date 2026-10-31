#!/bin/bash
# 4600H Live Monitor - refreshes EVERYTHING

while true; do
    clear
    echo "=============================================="
    echo " Ryzen 5 4600H - Live Monitor"
    echo " $(date '+%H:%M:%S')"
    echo "=============================================="
    echo ""

    # Governor
    GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    echo "GOVERNOR:  $GOV"
    echo ""

    # CPU Freq
    echo "--- CPU FREQ (MHz) ---"
    n=0
    grep "cpu MHz" /proc/cpuinfo | while read line; do
        freq=$(echo "$line" | awk '{print $4}')
        printf "  CPU%-2d: %.0f MHz\n" "$n" "$freq"
        n=$((n+1))
    done
    echo ""

    # Temp / Power
    echo "--- TEMP / POWER ---"
    sensors | grep -E "Tctl|PPT" | sed 's/^/  /'
    echo ""

    # PPT Limits (if ryzenadj available)
    if command -v ryzenadj &> /dev/null; then
        echo "--- PPT LIMITS ---"
        sudo -n ryzenadj -i 2>/dev/null | grep -E "STAPM LIMIT|PPT LIMIT FAST|PPT LIMIT APU" | sed 's/|/  /g' | sed 's/^/  /' || echo "  (need sudo)"
    fi
    echo ""

    echo "=============================================="
    echo " Ctrl+C = keluar | Refresh tiap 1 detik"
    sleep 1
done
