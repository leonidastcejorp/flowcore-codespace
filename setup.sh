#!/bin/bash
# setup.sh — One-command setup for Codespace
set -e
echo "🔧 Installing FlowCore Codespace Environment..."

# Install system deps
sudo apt-get update -qq
sudo apt-get install -y -qq python3-pip git curl wget unzip

# Install Python deps
pip install playwright aiohttp aiohttp-socks pyyaml 2>&1 | tail -3

# Install Playwright browser
playwright install chromium 2>&1 | tail -5
playwright install --with-deps chromium 2>&1 | tail -5

# Install Go (for security tools if needed)
if ! command -v go &> /dev/null; then
    wget -q https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
fi

echo "✅ FlowCore Codespace ready!"
echo ""
echo "📦 Available tools:"
echo "   python -m flowcore.modules.registrar --help"
echo "   python -m flowcore.modules.watcher"
echo "   python scripts/run_pipeline.py"
