#!/bin/bash
# ============================================================================
# scan_subs.sh
# Example: Subdomain enumeration & security scanning
# Usage: ./scan_subs.sh [target-file|domain]
#   With file:  ./scan_subs.sh targets.txt   (one domain per line)
#   With domain: ./scan_subs.sh example.com   (single target)
# ============================================================================

TARGET="${1:-targets.txt}"

# Get repo root
cd "$(dirname "$0")/.." || { echo "❌ Failed to cd to repo root"; exit 1; }
REPO_ROOT="$(pwd)"

echo "═══════════════════════════════════════════════"
echo "  🔍 FlowCore — Subdomain Scanner"
echo "═══════════════════════════════════════════════"
echo ""

# ── Check Go (needed for security tools) ──
if ! command -v go &>/dev/null; then
    echo "⚠️  Go not found. Run 'bash setup.sh' first."
    echo "   Or install manually:"
    echo "   wget -q https://go.dev/dl/go1.22.5.linux-amd64.tar.gz"
    echo "   sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz"
    echo "   export PATH=\$PATH:/usr/local/go/bin"
    exit 1
fi

# ── Ensure PATH includes Go tools ──
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

# ── Determine target(s) ──
if [ -f "$TARGET" ]; then
    echo "📂 Using target file: $TARGET"
    TARGET_TYPE="file"
elif [[ "$TARGET" == *.txt ]]; then
    echo "❌ File '$TARGET' not found."
    echo "   Create it with one domain per line."
    echo ""
    echo "   Example:"
    echo "     echo \"example.com\" > targets.txt"
    echo "     echo \"testsite.org\" >> targets.txt"
    exit 1
else
    echo "🎯 Single target: $TARGET"
    TARGET_TYPE="domain"
    # Create temp file
    echo "$TARGET" > /tmp/scan_targets_$$.txt
    TARGET="/tmp/scan_targets_$$.txt"
fi

# ── Install security tools if missing ──
TOOLS_MISSING=false
for tool in subfinder httpx; do
    if ! command -v "$tool" &>/dev/null; then
        echo "🔧 Installing $tool..."
        case "$tool" in
            subfinder)
                go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null
                ;;
            httpx)
                go install github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null
                ;;
        esac
        if ! command -v "$tool" &>/dev/null; then
            echo "   ⚠️  $tool install failed (may need GOPATH in PATH)"
            TOOLS_MISSING=true
        fi
    fi
done

# ── Run subfinder + httpx pipeline ──
echo ""
echo "🔍 Enumerating subdomains..."
echo "   (this may take a moment)"
echo ""

if command -v subfinder &>/dev/null && command -v httpx &>/dev/null; then
    OUTPUT_FILE="live_subs_$(date +%Y%m%d_%H%M%S).txt"

    subfinder -dL "$TARGET" -silent 2>/dev/null | \
        httpx -silent -title -status-code -o "$OUTPUT_FILE" 2>/dev/null

    echo ""
    if [ -f "$OUTPUT_FILE" ]; then
        LINE_COUNT=$(wc -l < "$OUTPUT_FILE")
        echo "✅ Scan complete! Found ${LINE_COUNT} live subdomains."
        echo "📄 Results saved to: $OUTPUT_FILE"
        echo ""
        echo "📋 Preview:"
        head -10 "$OUTPUT_FILE"
        if [ "$LINE_COUNT" -gt 10 ]; then
            echo "   ... and $(($LINE_COUNT - 10)) more"
        fi
    else
        echo "⚠️  No live subdomains found."
    fi
else
    echo "⚠️  Security tools not fully installed."
    echo ""
    echo "   Install manually:"
    echo "     go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    echo "     go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
    echo ""
    echo "   Then re-run this script."
fi

# Cleanup temp file
rm -f /tmp/scan_targets_$$.txt

echo ""
echo "💡 Next steps:"
echo "   - For vulnerability scanning: go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
echo "   - Then: nuclei -l live_subs_*.txt -severity critical,high -o critical.txt"
