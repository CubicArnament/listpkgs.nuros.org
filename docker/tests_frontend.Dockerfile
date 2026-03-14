# =============================================================================
# Frontend Tests Dockerfile - Playwright E2E Tests
# =============================================================================
# Runs Playwright end-to-end tests in headless mode.
# Uses official Playwright image with all required dependencies.
#
# Usage:
#   docker build -f docker/tests_frontend.Dockerfile -t nuros-frontend-tests .
# =============================================================================

# Use official Playwright image with Node.js and all browser dependencies
FROM mcr.microsoft.com/playwright:v1.58.2-jammy-node22

LABEL maintainer="NurOS Development Team"
LABEL description="Playwright E2E tests for frontend"

# Set environment
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV CI=true
ENV NODE_ENV=test

WORKDIR /app/listpkgs.nuros.front-end

# Enable corepack for pnpm (Node.js 22 includes corepack by default)
RUN corepack enable pnpm

# Copy package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile --prefer-offline

# Install Playwright browsers (Chromium for Desktop + Mobile Chrome tests)
# Pixel 5 emulation uses Chromium engine, so only chromium is needed
RUN pnpm exec playwright install chromium

# Copy source code
COPY listpkgs.nuros.front-end/ .

# Copy public assets (repodata.json if exists)
RUN if [ -f public/repodata.json ]; then echo "repodata.json found"; fi || echo "repodata.json not found (optional)"

# Run tests
CMD ["pnpm", "test"]
