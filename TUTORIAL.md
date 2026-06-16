# 📖 FlowCore Codespace — Complete Usage Guide

> *Your portable automation toolkit — run from anywhere, zero config. Built for GitHub Codespaces & Ubuntu 22.04/24.04.*

---

## 📑 Daftar Isi

- [🚀 Cara Mulai (Step by Step)](#-cara-mulai-step-by-step)
  - [Cara 1: GitHub Codespaces (Rekomendasi — Termudah)](#cara-1-github-codespaces-rekomendasi--termudah)
  - [Cara 2: Clone & Setup Manual](#cara-2-clone--setup-manual)
  - [Cara 3: GitHub Actions (Automated Jobs)](#cara-3-github-actions-automated-jobs)
- [📁 Struktur Folder](#-struktur-folder)
- [🛠️ Tools & Cara Pakai](#%EF%B8%8F-tools--cara-pakai)
  - [System Monitor](#system-monitor)
  - [Income Pipeline](#income-pipeline)
  - [Daily Report](#daily-report)
  - [Proxy Updater](#proxy-updater)
  - [Airdrop Monitor](#airdrop-monitor)
  - [Farming Guide](#farming-guide)
  - [Ghost Creator (Akun Discord, dll.)](#ghost-creator-akun-discord-dll)
  - [Ghost Tester](#ghost-tester)
  - [FlowCore Framework CLI](#flowcore-framework-cli)
- [⚙️ Setup Ulang / Re-Run](#%EF%B8%8F-setup-ulang--re-run)
- [📊 Automasi dengan GitHub Actions](#-automasi-dengan-github-actions)
- [💡 Pro Tips & Best Practices](#-pro-tips--best-practices)
- [❌ Troubleshooting — Yang Paling Sering Error](#-troubleshooting--yang-paling-sering-error)

---

## 🚀 Cara Mulai (Step by Step)

### Cara 1: GitHub Codespaces (Rekomendasi — Termudah)

Cocok untuk yang **tidak ingin install apa-apa di komputer lokal**. Semua jalan di cloud browser.

**Langkah-langkah:**

1. **Buka repo di browser:**
   https://github.com/leonidastcejorp/flowcore-codespace

2. **Klik tombol hijau** `Code` → pilih **Open with Codespaces**.

   ![Codespaces button](https://docs.github.com/assets/cb-138303/images/help/codespaces/new-codespace-button.png)
   *(Ilustrasi: tombol hijau di kanan atas)*

3. **Tunggu 1-2 menit.**
   - GitHub membuat container Ubuntu universal:2
   - `postCreateCommand` otomatis menjalankan `bash setup.sh`
   - Semua tools terinstall otomatis (Playwright, Go, Node, flowcore package)

4. **Verifikasi instalasi:**
   ```bash
   python3 tools/system_monitor.py
   ```
   Jika keluar laporan sistem (CPU, RAM, disk), berarti sukses! ✅

5. **Mulai pakai tools:**
   ```bash
   # Coba pipeline
   python3 tools/pipeline.py
   ```

> **Catatan**: Codespaces punya batas gratis ~60 jam/bulan (untuk akun GitHub gratis). Matikan codespace saat tidak dipakai biar kuota tidak habis.

### Cara 2: Clone & Setup Manual

Kalau mau jalan di **Ubuntu lokal** (22.04 atau 24.04) atau VPS:

```bash
# 1. Clone repo
git clone https://github.com/leonidastcejorp/flowcore-codespace.git
cd flowcore-codespace

# 2. Jalanin setup
bash setup.sh

# 3. Setup selesai — verifikasi
python3 tools/system_monitor.py
```

**Yang dilakukan setup.sh:**
- Deteksi OS (Ubuntu 22.04 vs 24.04)
- Pengecekan internet, disk, RAM (pre-flight check)
- Install system packages: python3-pip, git, curl, wget, unzip, ca-certificates
- Install Python deps: playwright, aiohttp, aiohttp-socks, pyyaml, requests, beautifulsoup4, lxml
- Install Playwright + Chromium (dengan `--with-deps`)
- Install **Go 1.22.5** (jika belum ada)
- Install **NVM + Node.js 20** (jika belum ada)
- Install **FlowCore** sebagai editable package dari `tools/flowcore/`
- Output summary ✅/❌ per step

**💡 Idempotent**: Setup bisa diulang kapan saja tanpa masalah. Step yang sudah berhasil akan di-skip.

### Cara 3: GitHub Actions (Automated Jobs)

Cocok untuk **menjalankan task terjadwal** meskipun codespace sedang mati.

**Buat workflow `.github/workflows/daily.yml`** di repo kamu:

```yaml
name: Daily Report
on:
  schedule:
    - cron: '0 6 * * *'   # Setiap jam 6 pagi UTC
  workflow_dispatch:        # Bisa juga di-trigger manual

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup & Run
        run: |
          pip install -r requirements.txt
          python3 tools/daily_report.py
```

**Penjelasan:**
- `schedule` : cron expression — `'0 6 * * *'` = tiap hari jam 06:00 UTC
- `workflow_dispatch` : biar bisa klik "Run workflow" manual dari tab Actions
- `runs-on: ubuntu-latest` : GitHub menyediakan runner Ubuntu gratis

**Contoh lain — Pipeline monitoring setiap 4 jam:**
```yaml
name: Monitor Pipeline
on:
  schedule:
    - cron: '0 */4 * * *'

jobs:
  pipeline:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Pipeline
        run: |
          pip install -r requirements.txt
          pip install playwright aiohttp aiohttp-socks
          playwright install --with-deps chromium
          python3 tools/pipeline.py --mode monitor --interval 300
```

---

## 📁 Struktur Folder

```
flowcore-codespace/
│
├── .devcontainer/
│   ├── devcontainer.json      # Config untuk GitHub Codespaces
│   │                         # (image universal:2, auto-run setup.sh)
│
├── tools/
│   ├── flowcore/              # Framework inti (Python package)
│   │   ├── setup.py           #   Package installer
│   │   ├── requirements.txt   #   Dependencies
│   │   ├── flowcore/          #   Source code
│   │   │   ├── core/          #     Browser, fingerprint engine
│   │   │   ├── modules/       #     Registrar, scraper, watcher
│   │   │   └── utils/         #     Names, network helpers
│   │   ├── config/            #   Configuration files
│   │   ├── scripts/           #   CLI entry points
│   │   └── tests/             #   Unit tests
│   │
│   ├── system_monitor.py      # 📈 System health check
│   ├── pipeline.py            # 💰 Income monitoring pipeline
│   ├── ghost_creator.py       # 👻 Mass account creator
│   ├── ghost_tester.py        # 🔍 Bypass / fingerprint tester
│   ├── farming_guide.py       # 🌾 Airdrop farming guide
│   ├── airdrop_monitor.py     # 📡 Airdrop scanner
│   ├── proxy_updater.py       # 🔄 Proxy list downloader
│   └── daily_report.py        # 📊 Daily report generator
│
├── examples/
│   ├── create_discord_accounts.sh   # Demo: bikin akun Discord
│   ├── run_pipeline.sh              # Demo: jalanin pipeline
│   └── scan_subs.sh                 # Demo: scan subdomain
│
├── setup.sh                  # 🚀 Auto-installer (idempotent)
├── requirements.txt          # Python dependencies (root)
├── README.md                 # Quick start (file ini ringkas)
└── TUTORIAL.md               # Kamu lagi baca ini
```

---

## 🛠️ Tools & Cara Pakai

### System Monitor

Cek kesehatan sistem dalam satu perintah:

```bash
python3 tools/system_monitor.py
```

**Contoh output:**
```
📡 System Health Report
CPU: 12% | RAM: 1.2/7.6GB (16%)
Disk: 4.1/32GB (13%) | Uptime: 2h 15m
```

Cocok dipakai setiap kali login untuk memastikan sistem siap.

### Income Pipeline

Memonitor peluang penghasilan dari berbagai sumber:

```bash
# Jalankan pipeline
python3 tools/pipeline.py

# Monitor dengan interval (detik)
python3 tools/pipeline.py --mode monitor --interval 60

# Satu kali scrape
python3 tools/pipeline.py --mode once
```

**Yang di-scrape:**
- Platform freelance (Upwork, Freelancer, PeoplePerHour)
- Testnet faucets dan airdrop opportunities
- Output: laporan terformat

### Daily Report

Buat laporan harian otomatis:

```bash
python3 tools/daily_report.py
```

**Output:**
- Statistik sistem hari ini
- Berita market/industri terkini
- Ringkasan aktivitas pipeline

### Proxy Updater

Download dan tes proxy gratis:

```bash
# Download fresh proxies
python3 tools/proxy_updater.py

# Hasil disimpan di ~/.flowcore/proxies/
# Format: http.txt, https.txt, socks5.txt
# Rata-rata: 5-50 proxy yang bekerja
```

**Cara pakai proxy dengan tools lain:**
```bash
python3 tools/ghost_creator.py --platform discord \
  --proxy-file ~/.flowcore/proxies/https.txt
```

### Airdrop Monitor

Pantau airdrop campaign terbaru:

```bash
# Cek airdrop
python3 tools/airdrop_monitor.py

# Filter chain tertentu
python3 tools/airdrop_monitor.py --chain ethereum

# Output: daftar airdrop terbaru + estimasi reward
```

**Sumber:**
- DropsTab
- QuestN
- Testnet faucets
- Social media mentions

### Farming Guide

Panduan interaktif untuk airdrop farming:

```bash
# Lihat semua topik
python3 tools/farming_guide.py

# Topik spesifik
python3 tools/farming_guide.py --topic bridge
python3 tools/farming_guide.py --topic swap
python3 tools/farming_guide.py --topic testnet

# Mode auto-farm (butuh API keys)
python3 tools/farming_guide.py --auto --chain sepolia
```

**Topik yang dicakup:**
| Topik | Deskripsi |
|-------|-----------|
| testnet | Farming token testnet (Sepolia, Goerli, dll.) |
| bridge | Bridge quests antar chain |
| swap | Swap & provide liquidity |
| stake | Staking airdrop |

### Ghost Creator (Akun Discord, dll.)

Buat akun secara massal dengan Playwright:

```bash
# Bikin 5 akun Discord
python3 tools/ghost_creator.py --platform discord --count 5

# Dengan proxy
python3 tools/ghost_creator.py --platform discord --count 10 \
  --proxy socks5://user:pass@ip:1080

# Simpan ke file
python3 tools/ghost_creator.py --platform discord --count 10 \
  --output accounts.json

# Pakai contoh script
bash examples/create_discord_accounts.sh 5
```

**Platform yang didukung:**
| Platform | Codespace | Notes |
|----------|-----------|-------|
| Discord | ✅ Works | No captcha |
| Fiverr | ⚠️ Limited | Butuh residential proxy |
| Reddit | ⚠️ Limited | Butuh phone verification |
| Gmail | ❌ Blocked | SMS verification required |

> 💡 **Keunggulan Codespace**: IP GitHub Codespaces lebih "bersih" daripada IP VPS datacenter — lebih jarang kena rate limit atau captcha.

### Ghost Tester

Test apakah suatu website bisa diakses via Playwright:

```bash
# Test URL
python3 tools/ghost_tester.py --url "https://example.com/login"

# Test dengan fingerprint khusus
python3 tools/ghost_tester.py --url "https://example.com" \
  --fingerprint "windows-chrome-120"

# Test proxy
python3 tools/ghost_tester.py --url "https://example.com" \
  --proxy socks5://user:pass@ip:1080
```

### FlowCore Framework CLI

Gunakan modul-modul framework secara langsung:

```bash
# Registrasi massal
python3 -m flowcore.modules.registrar --help

# Watcher (monitor otomatis)
python3 -m flowcore.modules.watcher

# Scraper
python3 -m flowcore.modules.scraper --source upwork --limit 20

# Refresh proxies via script
python3 -m flowcore.scripts.refresh_proxies

# Run pipeline via flowcore
python3 -m flowcore.scripts.run_pipeline
```

---

## ⚙️ Setup Ulang / Re-Run

Kapan saja kamu merasa ada tools yang hilang atau error:

```bash
# Re-run setup (idempotent — aman)
bash setup.sh

# Atau manual — install Python deps saja
pip install -r tools/flowcore/requirements.txt
pip install playwright aiohttp aiohttp-socks pyyaml

# Install ulang Chromium
playwright install --with-deps chromium

# Re-install flowcore package
cd tools/flowcore && pip install -e .
```

---

## 📊 Automasi dengan GitHub Actions

Karena Codespaces tidak punya systemd atau cron, gunakan **GitHub Actions** untuk task berulang.

### Workflow: Daily Report (setiap jam 6 pagi)

Buat file `.github/workflows/daily-report.yml`:

```yaml
name: 📊 Daily Report
on:
  schedule:
    - cron: '0 6 * * *'
  workflow_dispatch:

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install deps
        run: |
          pip install -r requirements.txt
          pip install playwright aiohttp aiohttp-socks pyyaml requests beautifulsoup4 lxml
          playwright install --with-deps chromium
      - name: Generate report
        run: python3 tools/daily_report.py
```

### Workflow: Airdrop Monitor (setiap 3 jam)

```yaml
name: 📡 Airdrop Scan
on:
  schedule:
    - cron: '0 */3 * * *'
  workflow_dispatch:

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup & Scan
        run: |
          pip install -r requirements.txt
          pip install playwright aiohttp pyyaml
          playwright install --with-deps chromium
          python3 tools/airdrop_monitor.py
```

### Menambahkan Secrets

Untuk API key atau credentials rahasia:

1. Buka repo → **Settings** → **Secrets and variables** → **Actions**
2. Klik **New repository secret**
3. Nama: `DISCORD_WEBHOOK_URL` (atau apapun)
4. Value: URL atau key kamu
5. Di workflow,akses via `${{ secrets.DISCORD_WEBHOOK_URL }}`

---

## 💡 Pro Tips & Best Practices

### Keep Codespace Alive

Secara default, Codespaces mati setelah **30 menit idle**. Untuk memperpanjang:

1. Buka Settings di Codespace
2. Set idle timeout (maks 240 menit di akun gratis)
3. Atau atur di `devcontainer.json`:
```json
"idleTimeout": 120
```

### Hemat Storage

Codespaces cuma punya ~32GB. Bersihkan secara berkala:

```bash
sudo apt clean
pip cache purge
rm -rf ~/.cache/*
```

### Multiple Terminals

Di VS Code Codespace:
- Buka terminal baru: `Ctrl+Shift+5` (split)
- Satu untuk pipeline berjalan
- Satu untuk command manual
- Satu untuk monitoring

### Environment Variables

Jangan simpan API key di file kode! Gunakan Codespaces secrets:

1. https://github.com/settings/secrets/codespaces
2. Tambah secret (misal: `OPENAI_API_KEY`, `DISCORD_TOKEN`)
3. Akses di Python:
```python
import os
api_key = os.environ.get("OPENAI_API_KEY")
```

### Gunakan `uv` untuk Install 10x Lebih Cepat

```bash
pip install uv
uv pip install -r requirements.txt
```

### Perbedaan dari VPS Version

| Feature | Codespace | VPS |
|---------|-----------|-----|
| **Persistence** | Session-based (mati saat idle) | Permanent 24/7 |
| **Cron** | GitHub Actions | System cron daemon |
| **Systemd** | ❌ No | ✅ Yes |
| **IP reputation** | 🟢 Cleaner | 🔴 Datacenter |
| **Storage** | ~32GB | 40GB+ |
| **Setup time** | ~1-2 menit auto | ~10 menit manual |
| **Biaya** | Gratis 60 jam/bulan | Bayar $5-20/bulan |

---

## ❌ Troubleshooting — Yang Paling Sering Error

### "playwright: command not found"

**Penyebab**: Playwright belum terinstall atau PATH tidak sesuai.

**Solusi:**
```bash
pip install playwright
playwright install --with-deps chromium
```

Atau jalankan ulang setup:
```bash
bash setup.sh
```

### "ModuleNotFoundError: No module named 'flowcore'"

**Penyebab**: FlowCore package belum diinstall.

**Solusi:**
```bash
cd tools/flowcore && pip install -e .
```

Verifikasi:
```bash
python3 -c "import flowcore; print(flowcore.__file__)"
# Harus ada output path
```

### "No space left on device"

**Penyebab**: Storage Codespace penuh (~32GB).

**Solusi:**
```bash
# Bersihkan cache apt
sudo apt clean

# Bersihkan pip cache
pip cache purge

# Bersihkan cache umum
rm -rf ~/.cache/*
du -sh ~/.cache   # Cek berapa yang terpakai

# Hapus Playwright browsers yang tidak dipakai
playwright uninstall chromium
playwright install chromium
```

### "Kena Rate Limit / 429 Too Many Requests"

**Penyebab**: Terlalu banyak request dalam waktu singkat.

**Solusi:**
1. **Gunakan proxy** — IP Codespace bisa kena rate limit juga
2. **Tambah delay** antar request
3. **Gunakan rotasi User-Agent** — flowcore sudah include ini
4. **Ganti IP** — matikan dan nyalakan ulang codespace (dapat IP baru)

Cek IP saat ini:
```bash
curl -s https://api.ipify.org
```

### "Chromium didn't start / Playwright errors"

**Penyebab**: Dependency sistem kurang.

**Solusi:**
```bash
# Reinstall total
playwright uninstall chromium
playwright install --with-deps chromium

# Atau install system libs manual
sudo apt-get install -y libnss3 libnspr4 libatk1.0-0 \
  libatk-bridge2.0-0 libcups2 libdrm2 libdbus-1-3 \
  libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
  libxrandr2 libgbm1 libpango-1.0-0 libcairo2 \
  libasound2 libatspi2.0-0
```

### "Git push rejected"

**Penyebab**: Branch ketinggalan dari remote.

**Solusi:**
```bash
git pull --rebase origin main
git push origin main
```

### "Codespace mati terlalu cepat"

**Penyebab**: Default idle timeout 30 menit.

**Solusi:**
- Settings codespace → perpanjang idle timeout
- Atau jalankan process di background supaya dianggap "aktif"

### "Workflow Actions tidak jalan"

**Penyebab**: Workflow belum di-push ke branch default, atau sintaks YAML salah.

**Solusi:**
1. Cek tab Actions di repo — ada error?
2. Validasi YAML di https://yamlchecker.com
3. Pastikan workflow ada di `.github/workflows/`
4. Trigger manual dulu (workflow_dispatch) sebelum test cron

---

## 🔗 Quick Links

| Resource | Link |
|----------|------|
| **Repository** | https://github.com/leonidastcejorp/flowcore-codespace |
| **VPS Version** | https://github.com/leonidastcejorp/flowcore-vps |
| **FlowCore Docs** | `cat tools/flowcore/README.md` |
| **Ghost Creator** | `python3 tools/ghost_creator.py --help` |
| **Pipeline** | `python3 tools/pipeline.py --help` |
| **System Monitor** | `python3 tools/system_monitor.py` |
| **Codepaces Docs** | https://docs.github.com/en/codespaces |

---

*Built with Hermes Agent · Part of the FlowCore Ecosystem*
*Last updated: June 2025*
