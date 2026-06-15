#!/bin/bash
# create_discord_accounts.sh
# Example: Create 5 Discord accounts using the ghost creator
# Usage: ./create_discord_accounts.sh [count]

set -e

COUNT=${1:-5}
echo "🔄 Creating ${COUNT} Discord accounts..."

cd "$(dirname "$0")/.."

if [ ! -f tools/ghost_creator.py ]; then
    echo "❌ tools/ghost_creator.py not found. Run setup.sh first."
    exit 1
fi

python tools/ghost_creator.py --count "${COUNT}" --output accounts/

echo "✅ Created ${COUNT} accounts in accounts/"
echo "📄 Check accounts/ for output files"
