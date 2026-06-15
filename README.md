# FlowCore Codespace

A lightweight, portable version of the FlowCore VPS agent toolkit, optimized for **GitHub Codespaces** (Ubuntu container, no systemd, portable paths).

## What's Included

| Directory | Contents |
|-----------|----------|
| `tools/flowcore/` | Full FlowCore framework (modules, core, utils, scripts, configs) |
| `tools/ghost_creator.py` | Discord account creation automation |
| `tools/ghost_tester.py` | Ghost account testing utilities |
| `tools/pipeline.py` | Income monitoring pipeline |
| `tools/farming_guide.py` | Airdrop farming guide & automation |
| `tools/airdrop_monitor.py` | Airdrop monitoring tool |
| `tools/proxy_updater.py` | Proxy list updater |
| `tools/daily_report.py` | Daily report generator |
| `tools/system_monitor.py` | System monitoring script |
| `examples/` | Example usage scripts |
| `.devcontainer/` | Codespace dev container configuration |

## Quick Start

### Option 1: GitHub Codespaces (Recommended)

1. Push this repo to GitHub
2. Click **"Code" → "Open with Codespaces"**
3. The post-create script runs automatically — wait for setup to finish

### Option 2: Manual Setup (Any Ubuntu system)

```bash
git clone <your-repo-url> flowcore-codespace
cd flowcore-codespace
bash setup.sh
```

### Option 3: VS Code Dev Containers

Open the folder in VS Code → Reopen in Container (requires Docker).

## Usage Examples

```bash
# Run the FlowCore registrar
python -m flowcore.modules.registrar --help

# Start the watcher
python -m flowcore.modules.watcher

# Run the pipeline
python tools/pipeline.py

# Create Discord accounts
bash examples/create_discord_accounts.sh

# Run monitoring pipeline
bash examples/run_pipeline.sh

# Run security scans
bash examples/scan_subs.sh
```

## Requirements

- GitHub Codespaces (recommended) or any Ubuntu 22.04+ system
- ~200MB disk space for tools + Playwright browsers
- Internet access for API calls

## Notes

- No systemd dependencies — all tools are portable scripts
- Playwright installs Chromium browser on first setup
- Go is installed for security tools (nuclei, etc.)
- Tool configs live in `tools/flowcore/config/`
