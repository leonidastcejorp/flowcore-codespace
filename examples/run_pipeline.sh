#!/bin/bash
# run_pipeline.sh
# Example: Run the monitoring pipeline
# Usage: ./run_pipeline.sh

set -e

echo "🔥 Starting FlowCore Monitoring Pipeline..."

cd "$(dirname "$0")/.."

if [ ! -f tools/pipeline.py ]; then
    echo "❌ tools/pipeline.py not found. Run setup.sh first."
    exit 1
fi

# Run the pipeline
python tools/pipeline.py --mode monitor --interval 60

echo "✅ Pipeline complete."
