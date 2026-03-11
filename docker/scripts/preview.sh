#!/bin/bash
# =============================================================================
# Preview - Generate repodata.json then build and start preview
# =============================================================================
# One command to:
# 1. Generate repodata.json using Python backend
# 2. Build frontend with repodata.json
# 3. Start nginx preview server
# =============================================================================

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo ""
echo "🔧 Step 1: Generating repodata.json..."
docker compose --profile preview run --rm generate-repodata || {
    echo "⚠️  Failed to generate repodata.json, continuing without it..."
}

echo ""
echo "📦 Step 2: Building and starting preview..."
docker compose --profile preview up --build preview
