#!/bin/bash
# 4600H Mode Switcher - GUI dengan zenity (BIOS TDP 54W, default ondemand)

export DISPLAY=${DISPLAY:-:0}

MODE=$(zenity --list --radiolist \
    --title="Ryzen 5 4600H - Mode Switcher" \
    --text="Pilih mode performa:" \
    --column="Pilih" --column="Mode" --column="Deskripsi" \
    TRUE "TURBO" "All-core 3.99GHz | PPT 54W | CO -15 | ondemand" \
    FALSE "BALANCED" "PPT 54W | CO -15 | ondemand (sama TURBO)" \
    FALSE "ECO" "PPT 25W | CO -10 | powersave (dingin senyap)" \
    FALSE "STOCK" "Reset ke default firmware" \
    FALSE "PERFORMANCE" "Paksa governor performance (buat latency rendah)" \
    --width=650 --height=340 2>/dev/null)

if [ -z "$MODE" ]; then
    exit 0
fi

case "$MODE" in
    "TURBO"|"BALANCED")
        echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        sudo ryzenadj --stapm-limit=54000 --fast-limit=54000 --slow-limit=54000 --apu-slow-limit=54000 --tctl-temp=95 --vrm-current=58000 --vrmsoc-current=15000 --vrmmax-current=96000 --vrmsocmax-current=20000 --set-coall=-15 > /dev/null 2>&1
        MSG="TURBO MODE ACTIVE\n\nAll-core: 3.99 GHz\nPPT: 54W\nUndervolt: CO -15\nGovernor: ondemand\n\nBoost tetap 3.99GHz saat load,\nhemat & senyap saat idle."
        ;;
    "ECO")
        echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        sudo ryzenadj --stapm-limit=25000 --fast-limit=30000 --slow-limit=30000 --apu-slow-limit=37500 --tctl-temp=100 --set-coall=-10 > /dev/null 2>&1
        MSG="ECO MODE ACTIVE\n\nPPT: 25W\nUndervolt: CO -10\nGovernor: powersave\nDingin & senyap"
        ;;
    "STOCK")
        echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        sudo ryzenadj --stapm-limit=54000 --fast-limit=54000 --slow-limit=54000 --apu-slow-limit=54000 --tctl-temp=100 --vrm-current=44000 --vrmsoc-current=13000 --vrmmax-current=70000 --vrmsocmax-current=17000 --set-coall=0 > /dev/null 2>&1
        MSG="STOCK MODE ACTIVE\n\nPPT: 54W (BIOS)\nCO: 0\nGovernor: ondemand"
        ;;
    "PERFORMANCE")
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
        sudo ryzenadj --stapm-limit=54000 --fast-limit=54000 --slow-limit=54000 --apu-slow-limit=54000 --tctl-temp=95 --vrm-current=58000 --vrmsoc-current=15000 --vrmmax-current=96000 --vrmsocmax-current=20000 --set-coall=-15 > /dev/null 2>&1
        MSG="PERFORMANCE MODE ACTIVE\n\nAll-core: 3.99 GHz\nPPT: 54W\nUndervolt: CO -15\nGovernor: performance\n\nCPU selalu di freq maksimal,\nlatency paling rendah."
        ;;
esac

zenity --info --title="4600H Mode" --text="$MSG" --width=400 2>/dev/null
