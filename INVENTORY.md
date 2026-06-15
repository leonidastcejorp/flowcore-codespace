# FlowCore Codespace — File Inventory

## Top-Level Files

| File | Source | Size |
|------|--------|------|
| `README.md` | Created for Codespace | Documentation |
| `setup.sh` | Created for Codespace | One-command setup script |
| `requirements.txt` | Created for Codespace | Python dependencies |

## `.devcontainer/`

| File | Source | Size |
|------|--------|------|
| `devcontainer.json` | Created for Codespace | Dev container config |

## `tools/`

| File | Source | Size |
|------|--------|------|
| `flowcore/` (directory) | Copied from `/root/flowcore/` | Full FlowCore framework |
| `ghost_creator.py` | Copied from `/root/bounty_output/ghost_creator.py` | 13.8K |
| `ghost_tester.py` | Copied from `/root/bounty_output/ghost_tester.py` | 6.6K |
| `pipeline.py` | Copied from `/root/bounty_output/income_pipeline.py` | 6.9K |
| `farming_guide.py` | Copied from `/root/airdrop_pipeline/farming_guide.py` | 5.3K |
| `airdrop_monitor.py` | Copied from `/root/airdrop_pipeline/monitor.py` | 4.5K |
| `proxy_updater.py` | Copied from `/root/.hermes/scripts/proxy_updater.py` | 3.3K |
| `daily_report.py` | Copied from `/root/.hermes/scripts/daily_report.py` | 7.0K |
| `system_monitor.py` | Copied from `/root/.hermes/scripts/monitor.py` | 4.9K |

### `tools/flowcore/` Contents

| Path | Description |
|------|-------------|
| `flowcore/` | Main Python package (core/, modules/, utils/) |
| `scripts/` | Pipeline and utility scripts |
| `config/` | Configuration files |
| `docs/` | Documentation |
| `tests/` | Test suite |
| `setup.py` | Package setup |
| `requirements.txt` | FlowCore dependencies |
| `LICENSE` | License file |

## `examples/`

| File | Description |
|------|-------------|
| `create_discord_accounts.sh` | Example: create N Discord accounts |
| `run_pipeline.sh` | Example: run the monitoring pipeline |
| `scan_subs.sh` | Example: run nuclei scan on targets |

## What's NOT Included (Installed Fresh by setup.sh)

- Python packages (installed via `requirements.txt`)
- Playwright browsers (installed by `playwright install chromium`)
- Go toolchain (installed by setup.sh)
- Nuclei / security scanner templates
- Cache directories (`__pycache__`, `.cache`)
- State databases (`*.db`, `*.sqlite`)
- Git history (`.git`)
- Binary archives (`*.tar.gz`, `*.zip`, `*.bin`)
