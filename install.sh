#!/bin/bash
# 4600H Toolkit Installer
# Jalankan: bash install.sh

set -e

echo "=============================================="
echo " Ryzen 5 4600H Performance Toolkit Installer"
echo "=============================================="
echo ""

# Check root
if [ "$EUID" -eq 0 ]; then
    echo "Jangan jalankan sebagai root. Pakai user biasa + sudo."
    exit 1
fi

# 1. Dependencies
echo "[1/6] Install dependencies..."
sudo apt-get update -qq
sudo apt-get install -y ryzenadj lm-sensors stress-ng zenity cpufrequtils linux-tools-common git build-essential

# 2. Build ryzen_smu
echo "[2/6] Build ryzen_smu..."
if ! lsmod | grep -q ryzen_smu; then
    if [ ! -d /tmp/ryzen_smu ]; then
        git clone --depth 1 https://github.com/amkillam/ryzen_smu.git /tmp/ryzen_smu
    fi
    cd /tmp/ryzen_smu
    make clean 2>/dev/null || true
    make KERNELVER=$(uname -r)
    sudo mkdir -p /lib/modules/$(uname -r)/extra
    sudo cp ryzen_smu.ko /lib/modules/$(uname -r)/extra/
    sudo depmod -a $(uname -r)
    sudo modprobe ryzen_smu
    cd - > /dev/null
fi

# 3. Install scripts
echo "[3/6] Install scripts..."
sudo cp 4600h_unlock.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/4600h_unlock.sh
cp 4600h_mode.sh 4600h_monitor.sh 4600h_verify.sh ~/
chmod +x ~/4600h_mode.sh ~/4600h_monitor.sh ~/4600h_verify.sh

# 4. Install services
echo "[4/6] Install systemd services..."
sudo cp 4600h-unlock.service /etc/systemd/system/
sudo cp ryzenadj.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable 4600h-unlock.service ryzenadj.service

# 5. Install rules
echo "[5/6] Install udev + polkit rules..."
sudo cp 99-ryzen-smu.rules /etc/udev/rules.d/
sudo cp corectrl.rules /usr/share/polkit-1/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

# 6. Governor
echo "[6/6] Set governor..."
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils > /dev/null
sudo systemctl enable cpufrequtils 2>/dev/null || true

# Disable XFCE Power Manager autostart (kalau ada)
if [ -f /etc/xdg/autostart/xfce4-power-manager.desktop ]; then
    mkdir -p ~/.config/autostart
    cp /etc/xdg/autostart/xfce4-power-manager.desktop ~/.config/autostart/
    echo "Hidden=true" >> ~/.config/autostart/xfce4-power-manager.desktop
fi

echo ""
echo "=============================================="
echo " INSTALASI SELESAI!"
echo "=============================================="
echo ""
echo " Scripts terinstall di ~/:"
echo "   4600h_mode.sh     - Mode switcher"
echo "   4600h_monitor.sh  - Monitor real-time"
echo "   4600h_verify.sh   - Stress test + verdict"
echo ""
echo " Services aktif:"
echo "   4600h-unlock.service"
echo "   ryzenadj.service"
echo "   cpufrequtils.service"
echo ""
echo " Reboot untuk apply semua setting."
echo "=============================================="
