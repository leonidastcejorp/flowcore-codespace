# 📖 FlowCore Codespace — Complete Usage Guide

> *Your portable automation toolkit — run from anywhere, zero config. Built for GitHub Codespaces.*

---

## 📑 Table of Contents

- [🚀 Getting Started](#-getting-started)
- [📁 Repository Layout](#-repository-layout)
- [🎯 Using the Tools](#-using-the-tools)
- [👻 Ghost Framework](#-ghost-framework)
- [🌐 Airdrop Farming](#-airdrop-farming)
- [📡 Security Scanning](#-security-scanning)
- [🔄 Proxy Management](#-proxy-management)
- [📊 Daily Reports & Monitoring](#-daily-reports--monitoring)
- [⚡ Pro Tips](#-pro-tips)
- [🐛 Troubleshooting](#-troubleshooting)

---

## 🚀 Getting Started

### Option 1: GitHub Codespaces (2 clicks)

```bash
# Just open in browser — everything's pre-configured
# No setup required beyond clicking "Open in Codespaces"
```

1. Go to https://github.com/leonidastcejorp/flowcore-codespace
2. Click **Code** → **Open with Codespaces**
3. Wait ~30 seconds — postCreateCommand runs automatically
4. Run `python3 tools/system_monitor.py` to verify ✅

### Option 2: Clone & Run Anywhere

```bash
git clone https://github.com/leonidastcejorp/flowcore-codespace.git
cd flowcore-codespace
bash setup.sh
```

### Verification

```bash
# Check everything installed
python3 --version         # ≥ 3.10 ✅
go version                  # ≥ 1.21 ✅
node --version             # ≥ 18 ✅
playwright --version        # Should show version ✅
python3 tools/system_monitor.py  # Test run ✅
```

---

## 📁 Repository Layout

```
flowcore-codespace/
├── .devcontainer/          # Codespace configuration
│   ├── devcontainer.json   #   Container definition
│   └── Dockerfile          #   Custom image build
├── tools/                  # All executable tools
│   ├── flowcore/           #   Full framework (core, modules, utils)
│   ├── ghost_creator.py    #   👻 Mass account creator
│   ├── ghost_tester.py     #   🔍 Bypass tester
│   ├── pipeline.py         #   💰 Income pipeline
│   ├── farming_guide.py    #   🌾 Airdrop strategies
│   ├── airdrop_monitor.py  #   📡 Airdrop scanner
│   ├── proxy_updater.py    #   🔄 Proxy refresh
│   ├── daily_report.py     #   📊 Report generator
│   └── system_monitor.py   #   📈 System health
├── examples/               # Ready-to-run examples
│   ├── create_discord_accounts.sh
│   ├── run_pipeline.sh
│   └── scan_subs.sh
├── setup.sh                # Auto-install script
├── requirements.txt        # Python deps
├── README.md               # Quickstart
└── TUTORIAL.md             # This file
```

---

## 🎯 Using the Tools

### System Monitor

```bash
# Quick health check
python3 tools/system_monitor.py

# Sample output:
# 📡 System Health Report
# CPU: 12% | RAM: 1.2/7.6GB (16%)
# Disk: 4.1/32GB (13%) | Uptime: 2h 15m
```

### Income Pipeline

```bash
# Run the opportunity scraper
python3 tools/pipeline.py

# Scrapes: Upwork, Freelancer, PeoplePerHour
# + Testnet faucets and airdrop opportunities
# Output: formatted report sent to configured destination
```

### Daily Report

```bash
# Generate a daily briefing
python3 tools/daily_report.py

# Shows: system stats + recent market/industry news
```

### Proxy Updater

```bash
# Download & test fresh proxies
python3 tools/proxy_updater.py

# Sources: 4 public proxy lists
# Result: ~5-50 working proxies saved to ~/.flowcore/proxies/
```

### Airdrop Monitor

```bash
# Check latest airdrop campaigns
python3 tools/airdrop_monitor.py

# Scans: DropsTab, QuestN, testnet faucets
# Output: categorized list with reward estimates
```

### Farming Guide

```bash
# View airdrop strategies
python3 tools/farming_guide.py

# Covers: testnet farming, bridge quests, staking airdrops
# Interactive mode with step-by-step instructions
```

---

## 👻 Ghost Framework

### Create Accounts

```bash
# Discord — works from anywhere
python3 tools/ghost_creator.py --platform discord --count 5

# With proxy for tricky platforms
python3 tools/ghost_creator.py --platform fiverr --proxy socks5://user:pass@ip:1080

# Save to file
python3 tools/ghost_creator.py --platform discord --count 10 --output accounts.json

# Using the example script
bash examples/create_discord_accounts.sh
```

### Test Bypass Capabilities

```bash
# Test Turnstile/Cloudflare bypass
python3 tools/ghost_tester.py --url "https://example.com/login"

# Test with custom fingerprint
python3 tools/ghost_tester.py --url "https://example.com" --fingerprint "windows-chrome-120"
```

### Platform Compatibility

| Platform | Codespace | VPS | Notes |
|----------|-----------|-----|-------|
| Discord | ✅ Works | ✅ | No captcha needed |
| Fiverr | ⚠️ Limited | ❌ Blocked | Needs residential proxy |
| Reddit | ⚠️ Limited | ❌ Blocked | Phone verification |
| Gmail | ❌ Blocked | ❌ Blocked | SMS verification |

> 💡 **Codespace advantage**: GitHub Codespaces IPs are less aggressively blocked than VPS datacenter IPs!

---

## 🌐 Airdrop Farming

The farming guide covers these testnet/airdrop strategies:

### Testnet Faucets

| Chain | Faucet URL | Token | Difficulty |
|-------|------------|-------|------------|
| Sepolia ETH | faucet.sepolia.dev | sETH | 🟢 Easy |
| Goerli ETH | goerlifaucet.com | gETH | 🟢 Easy |
| Polygon Mumbai | faucet.polygon.technology | MATIC | 🟡 Medium |
| Avalanche Fuji | faucet.avax.network | AVAX | 🟢 Easy |
| BSC Testnet | testnet.binance.org/faucet-smart | BNB | 🟡 Medium |

### Bridge & Swap

```bash
# Step-by-step guide for:
python3 tools/farming_guide.py --topic bridge
python3 tools/farming_guide.py --topic swap
```

### Auto-Farm

```bash
# Run with automation (requires API keys)
python3 tools/farming_guide.py --auto --chain sepolia
```

> ⚠️ **Note**: Manual steps (captchas, SMS) can't be fully automated — the guide tells you exactly when to intervene.

---

## 📡 Security Scanning

### Subdomain Enumeration

```bash
# Install scanning tools
bash examples/scan_subs.sh

# Or run a manual scan
subfinder -d example.com -silent | httpx -silent > live_subs.txt

# Scan for vulnerabilities (if nuclei installed)
nuclei -l live_subs.txt -severity critical,high -o critical.txt
```

### One-Line Recon

```bash
subfinder -d target.com -silent | httpx -silent | nuclei -severity critical,high
```

> 💡 Codespaces have clean IPs — less likely to be rate-limited than VPS.

---

## 🔄 Proxy Management

### Quick Start

```bash
# Download and test proxies
python3 tools/proxy_updater.py

# Use with ghost creator
python3 tools/ghost_creator.py --platform fiverr --proxy-file ~/.flowcore/proxies/https.txt
```

### Manual Proxy Test

```bash
# Test a single proxy
curl -x http://1.2.3.4:8080 -s -o /dev/null -w "%{http_code}" https://api.ipify.org

# Should return 200 for working proxies
```

---

## 📊 Daily Reports & Monitoring

Set up recurring monitoring with GitHub Actions:

1. Go to your repo **Actions** tab
2. Add a workflow (`.github/workflows/daily.yml`):

```yaml
name: Daily Report
on:
  schedule:
    - cron: '0 6 * * *'  # Every day at 6 AM UTC
  workflow_dispatch:

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Report
        run: |
          pip install -r requirements.txt
          python3 tools/daily_report.py
```

Optionally configure **Slack/Discord/Telegram notifications** via Actions.

---

## ⚡ Pro Tips

| Tip | Description |
|-----|-------------|
| **Keep Codespace alive** | Use `gh codespace list` to check; set `"idleTimeout": "120m"` in devcontainer.json |
| **Skip reinstall** | Your codespace persists — tools stay installed across sessions |
| **Use `uv`** | `pip install uv && uv pip install -r requirements.txt` for 10x faster installs |
| **Multiple terminals** | Split in VS Code: one for pipelines, one for manual commands |
| **Port forwarding** | Codespaces can expose ports (useful for browser automation debugging) |
| **Environment vars** | Set sensitive keys in Codespaces secrets, not in code |
| **GitHub Actions** | Automate pipeline runs even when codespace is stopped |
| **Storage limit** | Codespaces have ~32GB — run `sudo apt clean` periodically |
| **Different from VPS** | No systemd, no persistent cron; use Actions for scheduling |

### Differences from VPS Version

| Feature | Codespace Version | VPS Version |
|---------|------------------|-------------|
| **Persistence** | Session-based | Permanent |
| **Cron jobs** | GitHub Actions | Cron daemon |
| **Systemd** | ❌ No | ✅ Yes |
| **Credentials** | Codespace secrets | Config files |
| **IP reputation** | 🟢 Cleaner | 🔴 Datacenter |
| **Storage** | ~32GB | 40GB |
| **Setup time** | 30 seconds | ~10 minutes |

---

## 🐛 Troubleshooting

### Codespace Won't Open

```bash
# Delete and recreate
gh codespace delete
gh codespace create -R leonidastcejorp/flowcore-codespace -b main
```

### Tools Not Found

```bash
# Reinstall
bash setup.sh

# Or manually
pip install -r requirements.txt
playwright install --with-deps chromium
```

### "No space left"

```bash
# Clean
sudo apt clean
pip cache purge
rm -rf ~/.cache/*
```

### Playwright Errors

```bash
# Reinstall browser
playwright uninstall chromium
playwright install chromium
```

### Can't Push Changes

```bash
git pull --rebase origin main
git push origin main
```

### Secrets / API Keys

```bash
# For sensitive keys, always use Codespaces secrets:
# 1. Go to github.com/settings/secrets/codespaces
# 2. Add your API keys
# 3. Access in code via os.environ.get("OPENAI_API_KEY")
```

---

## 🔗 Quick Links

| Resource | Link |
|----------|------|
| Repo | https://github.com/leonidastcejorp/flowcore-codespace |
| VPS Backup | https://github.com/leonidastcejorp/flowcore-vps |
| Ghost Framework | `python3 tools/ghost_creator.py --help` |
| Airdrop Guide | `python3 tools/farming_guide.py` |
| Pipeline | `python3 tools/pipeline.py` |

---

*Built with Hermes Agent · Part of the FlowCore Ecosystem*
