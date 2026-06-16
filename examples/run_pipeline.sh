#!/bin/bash
# ============================================================================
# run_pipeline.sh
# Example: Run the FlowCore income monitoring pipeline
# Usage: ./run_pipeline.sh [mode] [interval]
#   mode:     once | monitor (default: once)
#   interval: seconds between checks (default: 60, only in monitor mode)
# ============================================================================

MODE="${1:-once}"
INTERVAL="${2:-60}"

# Get repo root
cd "$(dirname "$0")/.." || { echo "❌ Failed to cd to repo root"; exit 1; }
REPO_ROOT="$(pwd)"

echo "═══════════════════════════════════════════════"
echo "  🔥 FlowCore — Monitoring Pipeline"
echo "═══════════════════════════════════════════════"
echo ""

# ── Check setup ──
if [ ! -f "$REPO_ROOT/tools/pipeline.py" ]; then
    echo "❌ tools/pipeline.py not found."
    echo "   Run 'bash setup.sh' first."
    exit 1
fi

# Check flowcore package
python3 -c "import flowcore" 2>/dev/null || {
    echo "⚠️  flowcore package not installed. Installing..."
    cd "$REPO_ROOT/tools/flowcore" && pip install -e . || {
        echo "❌ Failed to install flowcore package."
        exit 1
    }
    cd "$REPO_ROOT"
}

# Check Playwright
python3 -c "from playwright.sync_api import sync_playwright" 2>/dev/null || {
    echo "⚠️  Playwright not properly installed. Installing..."
    pip install playwright && python3 -m playwright install --with-deps chromium || {
        echo "❌ Failed to install Playwright."
        exit 1
    }
}

# ── Run pipeline ──
echo "📍 Mode: ${MODE}"
if [ "$MODE" = "monitor" ]; then
    echo "⏱️  Interval: ${INTERVAL}s"
fi
echo ""

python3 tools/pipeline.py --mode "${MODE}" --interval "${INTERVAL}"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Pipeline completed successfully."
else
    echo "⚠️  Pipeline exited with code ${EXIT_CODE}"
    echo "   Check error messages above."
fi

echo ""
echo "💡 Next steps:"
echo "   - Run 'python3 tools/daily_report.py' for a summary"
echo "   - Check 'python3 tools/airdrop_monitor.py' for opportunities"
