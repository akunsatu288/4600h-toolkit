#!/bin/bash
# 4600H Performance Verify Script
# Jalankan: bash /home/isal/4600h_verify.sh

echo "=============================================="
echo " Ryzen 5 4600H Performance Check"
echo " $(date)"
echo "=============================================="
echo ""
echo "KERNEL:      $(uname -r)"
echo "GOVERNOR:    $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
echo "BOOST:       $(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null)"
echo "ACPI PSTATE: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies)"
echo ""
echo "--- POWER LIMITS (ryzenadj) ---"
ryzenadj -i 2>/dev/null | grep -E "STAPM LIMIT|PPT LIMIT FAST|PPT LIMIT SLOW|PPT LIMIT APU|TDC LIMIT VDD|EDC LIMIT VDD|THM LIMIT"
echo ""
echo "--- 30s SUSTAINED LOAD TEST ---"
echo "Monitoring freq/power/temp during all-core load..."
echo ""

stress-ng --cpu 12 --cpu-method matrixprod --timeout 30s --metrics-brief > /tmp/4600h_stress.log 2>&1 &
MONPID=$!

MAXF=0
SUMF=0
COUNT=0
MAXT=0
MAXP=0

for i in $(seq 1 15); do
    sleep 2
    F=$(cat /sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq)
    FM=$((F / 1000))
    T=$(sensors | grep Tctl | awk '{print $2}' | tr -d '+°C')
    P=$(sensors | grep PPT | awk '{print $2}' | tr -d 'W ')
    echo "  t=$((i*2))s  freq=${FM}MHz  Tctl=${T}°C  PPT=${P}W"
    if [ $FM -gt $MAXF ]; then MAXF=$FM; fi
    SUMF=$((SUMF + FM))
    COUNT=$((COUNT + 1))
    TI=${T%.*}
    if [ $TI -gt $MAXT ]; then MAXT=$TI; fi
    PI=${P%.*}
    if [ $PI -gt $MAXP ]; then MAXP=$PI; fi
done

wait $MONPID

AVGF=$((SUMF / COUNT))

echo ""
echo "=============================================="
echo " HASIL 30s SUSTAINED ALL-CORE LOAD"
echo "=============================================="
echo "  Max Freq:     ${MAXF} MHz"
echo "  Avg Freq:     ${AVGF} MHz"
echo "  Max Tctl:     ${MAXT}°C"
echo "  Max PPT:      ${MAXP}W"
echo ""
grep -E "successful|failed" /tmp/4600h_stress.log
echo ""
echo "=============================================="
echo " VERDICT"
echo "=============================================="
if [ $AVGF -ge 3200 ]; then
    echo "  ALL-CORE BOOST AKTIF (${AVGF}MHz > 3.0GHz base)"
elif [ $AVGF -ge 3000 ]; then
    echo "  ALL-CORE DI BASE 3.0GHz (tidak throttle, tidak boost)"
else
    echo "  ALL-CORE DI BAWAH 3.0GHz (${AVGF}MHz) - throttle?"
fi
echo ""
echo "  Thermal headroom: $((100 - MAXT))°C"
if [ $MAXT -lt 80 ]; then
    echo "  Thermal OK"
else
    echo "  Thermal tinggi - cek cooling"
fi
echo "=============================================="
