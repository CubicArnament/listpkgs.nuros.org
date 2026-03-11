# =============================================================================
# Preview - Generate repodata.json then build and start preview
# =============================================================================
# One command to:
# 1. Generate repodata.json using Python backend
# 2. Build frontend with repodata.json
# 3. Start nginx preview server
# =============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "🔧 Step 1: Generating repodata.json..." -ForegroundColor Cyan
docker compose --profile preview run --rm generate-repodata
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Failed to generate repodata.json, continuing without it..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📦 Step 2: Building and starting preview..." -ForegroundColor Cyan
docker compose --profile preview up --build preview
