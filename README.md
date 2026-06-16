# 🧩 FlowCore Codespace

> *Portable automation toolkit for GitHub Codespaces & Ubuntu — accounts, monitoring, scraping, pipelines.*

[![Open in Codespaces](https://img.shields.io/badge/Open_in_Codespaces-1f883d?style=for-the-badge&logo=github&logoColor=white)](https://github.com/leonidastcejorp/flowcore-codespace)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-E95420?style=flat&logo=ubuntu)](https://ubuntu.com/)
[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?style=flat&logo=python)](https://python.org)

---

## ✨ What's Inside

| Directory | Description |
|-----------|-------------|
| `tools/flowcore/` | Core framework — modules, browser automation, utils |
| `tools/*.py` | Standalone tools: ghost creator, pipeline, monitors |
| `examples/` | Ready-to-run shell scripts |
| `.devcontainer/` | Codespace auto-configuration |
| `setup.sh` | One-command installer (idempotent) |

## 🚀 Quick Start

### Option 1: GitHub Codespaces (Recommended — 2 clicks)
Just click the badge above or:
1. Go to **[github.com/leonidastcejorp/flowcore-codespace](https://github.com/leonidastcejorp/flowcore-codespace)**
2. Click **Code** → **Open with Codespaces**
3. Wait ~1-2 min — setup runs automatically
4. Terminal is ready: `python3 tools/system_monitor.py`

### Option 2: Manual (Any Ubuntu 22.04/24.04)
```bash
git clone https://github.com/leonidastcejorp/flowcore-codespace.git
cd flowcore-codespace
bash setup.sh
```

### Option 3: GitHub Actions (Scheduled Jobs)
Even when your codespace is stopped, you can schedule runs via Actions.
See **[TUTORIAL.md](TUTORIAL.md)** for a full guide.

---

## 🛠️ Tools Overview

```bash
# System health
python3 tools/system_monitor.py

# Income pipeline (monitoring & scraping)
python3 tools/pipeline.py

# Ghost account creator (Discord, etc.)
python3 tools/ghost_creator.py --platform discord --count 3

# FlowCore framework
python3 -m flowcore.modules.registrar --help
python3 -m flowcore.modules.watcher

# Example scripts
bash examples/create_discord_accounts.sh
bash examples/run_pipeline.sh
bash examples/scan_subs.sh subs.txt
```

## 📖 Documentation

- **[TUTORIAL.md](TUTORIAL.md)** — Step-by-step usage guide (🇮🇩 Indonesian)
- **`cat tools/flowcore/README.md`** — FlowCore package docs

## 💡 Key Features

- **Codespace-optimized**: No systemd, no persistent cron — uses GitHub Actions for scheduling
- **Clean IPs**: GitHub Codespaces IPs are less aggressively blocked than VPS datacenter IPs
- **Idempotent setup**: Run `bash setup.sh` any number of times
- **32GB storage**: Codespace standard — `sudo apt clean` to free space
- **Pre-installed**: Python 3.10+, Git, Docker (on Codespaces) already available

## 📄 License

MIT — see [LICENSE](tools/flowcore/LICENSE).
