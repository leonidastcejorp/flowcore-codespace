#!/bin/bash
# ============================================================================
# create_discord_accounts.sh
# Example: Create Discord accounts using the ghost creator
# Usage: ./create_discord_accounts.sh [count] [output-dir]
# ============================================================================

COUNT=${1:-5}
OUTPUT_DIR="${2:-accounts}"

# Get repo root
cd "$(dirname "$0")/.." || { echo "❌ Failed to cd to repo root"; exit 1; }
REPO_ROOT="$(pwd)"

echo "═══════════════════════════════════════════════"
echo "  👻 FlowCore — Create Discord Accounts"
echo "═══════════════════════════════════════════════"
echo ""

# ── Check setup ──
if [ ! -f "$REPO_ROOT/tools/ghost_creator.py" ]; then
    echo "❌ tools/ghost_creator.py not found."
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

# ── Create output directory ──
mkdir -p "$OUTPUT_DIR"

# ── Run ghost creator ──
echo "🔄 Creating ${COUNT} Discord accounts..."
echo "   Output dir: ${OUTPUT_DIR}/"
echo ""

python3 tools/ghost_creator.py \
    --platform discord \
    --count "${COUNT}" \
    --output "${OUTPUT_DIR}/discord_accounts_$(date +%Y%m%d_%H%M%S).json"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Accounts created successfully!"
    echo "📄 Check ${OUTPUT_DIR}/ for output files"
else
    echo "⚠️  Ghost creator exited with code ${EXIT_CODE}"
    echo "   Check error messages above."
fi

echo ""
echo "📋 Output files:"
ls -lh "${OUTPUT_DIR}/" 2>/dev/null || echo "   (no files)"
