# Ryzen 5 4600H Performance Toolkit

Optimasi lengkap untuk Mini PC AMD Ryzen 5 4600H (Zen 2 Renoir) dengan firmware P-state lock.

## Hasil

| Metric | Sebelum | Sesudah |
|---|---|---|
| All-core freq | 3.0 GHz (stuck) | **3.8-4.0 GHz** |
| Single-core | 3.0 GHz | **4.0 GHz** |
| PPT power | 11W (capped) | **44-48W** |
| Thermal | 55°C | 86°C (aman, 13°C headroom) |
| Stabilitas | - | 0 failed / 60s |

## Isi Repo

```
4600h_unlock.sh       Apply semua setting (governor + PPT + CO)
4600h_mode.sh         GUI mode switcher (TURBO/BALANCED/ECO/STOCK)
4600h_monitor.sh      Monitor real-time (freq/temp/power)
4600h_verify.sh       Stress test 30s + verdict

4600h-unlock.service  Systemd service (auto-apply saat boot)
ryzenadj.service      Systemd service (PPT + undervolt)
99-ryzen-smu.rules    Udev rule (permission ryzen_smu)
corectrl.rules        Polkit rule (CoreCtrl access)

install.sh            Installer otomatis
```

## Quick Start

```bash
git clone https://github.com/USER/4600h-toolkit.git
cd 4600h-toolkit
bash install.sh
```

## Manual Install

### 1. Dependencies

```bash
sudo apt-get install -y ryzenadj lm-sensors stress-ng zenity linux-tools-common
```

### 2. Build ryzen_smu (kalau belum ada)

```bash
cd /tmp
git clone --depth 1 https://github.com/amkillam/ryzen_smu.git
cd ryzen_smu
make KERNELVER=$(uname -r)
sudo mkdir -p /lib/modules/$(uname -r)/extra
sudo cp ryzen_smu.ko /lib/modules/$(uname -r)/extra/
sudo depmod -a $(uname -r)
sudo modprobe ryzen_smu
```

### 3. Install Scripts

```bash
sudo cp 4600h_unlock.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/4600h_unlock.sh

cp 4600h_mode.sh 4600h_monitor.sh 4600h_verify.sh ~/
chmod +x ~/4600h_*.sh
```

### 4. Install Services

```bash
sudo cp 4600h-unlock.service /etc/systemd/system/
sudo cp ryzenadj.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable 4600h-unlock.service ryzenadj.service
```

### 5. Install Rules

```bash
sudo cp 99-ryzen-smu.rules /etc/udev/rules.d/
sudo cp corectrl.rules /usr/share/polkit-1/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### 6. Governor Persistent

```bash
sudo apt-get install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo systemctl enable cpufrequtils
```

## Mode Switcher

```bash
bash ~/4600h_mode.sh
```

| Mode | Governor | PPT | CO | Kegunaan |
|---|---|---|---|---|
| TURBO | performance | 45W | -20 | Gaming/rendering/compile |
| BALANCED | ondemand | 45W | -20 | Daily driver |
| ECO | powersave | 25W | -10 | Dingin & senyap |
| STOCK | ondemand | 25W | 0 | Reset ke default |

## Monitor

```bash
bash ~/4600h_monitor.sh
```

Real-time: freq per-core, governor, Tctl, PPT.

## Verify

```bash
bash ~/4600h_verify.sh
```

30s stress test + verdict (freq/temp/power).

## Troubleshooting

### Governor reset ke ondemand
```bash
# Matikan XFCE Power Manager autostart
cp /etc/xdg/autostart/xfce4-power-manager.desktop ~/.config/autostart/
echo "Hidden=true" >> ~/.config/autostart/xfce4-power-manager.desktop

# Matikan cpupower-gui-helper (kalau ada)
sudo systemctl stop cpupower-gui-helper
```

### ryzenadj "Unable to get os_access"
```bash
# Pastikan ryzen_smu loaded
sudo modprobe ryzen_smu

# Cek permission
ls -la /sys/kernel/ryzen_smu_drv/
```

### Kernel baru, module hilang
```bash
# Rebuild ryzen_smu untuk kernel baru
cd /tmp/ryzen_smu
make clean
make KERNELVER=$(uname -r)
sudo cp ryzen_smu.ko /lib/modules/$(uname -r)/extra/
sudo depmod -a $(uname -r)
```

### Kernel 6.8 no WiFi/LAN
```bash
sudo apt-get install -y linux-modules-extra-$(uname -r)
```

## Catatan

- Undervolt CO -20 sudah tested aman (0 failed / 60s stress)
- Jangan push CO lebih dari -25 (bisa instabil)
- Fan controlled by firmware, tidak bisa dikontrol dari Linux
- Kernel 6.8.0-147-generic direkomendasikan (HWE, support sampai 2029)

## Credits

- [ryzenadj](https://github.com/FlyGoat/RyzenAdj) - PPT/CO control
- [ryzen_smu](https://github.com/amkillam/ryzen_smu) - SMU kernel module
- [CoreCtrl](https://gitlab.com/corectrl/corectrl) - GUI monitoring
