#!/bin/bash
# scan_subs.sh
# Example: Run nuclei scan on a target list
# Usage: ./scan_subs.sh targets.txt

set -e

TARGETS=${1:-targets.txt}

cd "$(dirname "$0")/.."

if [ ! -f "${TARGETS}" ]; then
    echo "❌ Target list '${TARGETS}' not found."
    echo "   Create a file with one domain per line."
    echo ""
    echo "Example targets.txt:"
    echo "  example.com"
    echo "  testsite.org"
    exit 1
fi

if ! command -v nuclei &> /dev/null; then
    echo "⚠️  nuclei not found. Install it first:"
    echo "   go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    exit 1
fi

echo "🔍 Scanning targets from ${TARGETS}..."
echo ""

nuclei -l "${TARGETS}" -severity low,medium,high,critical -o scan_results.txt

echo ""
echo "✅ Scan complete. Results in scan_results.txt"
