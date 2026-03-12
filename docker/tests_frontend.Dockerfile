# =============================================================================
# Frontend Tests Dockerfile - Playwright E2E Tests
# =============================================================================
# Runs Playwright end-to-end tests in headless mode.
# Includes Chromium browser and all required dependencies.
#
# Usage:
#   docker build -f docker/tests_frontend.Dockerfile -t nuros-frontend-tests .
# =============================================================================

FROM node:22-alpine

LABEL maintainer="NurOS Development Team"
LABEL description="Playwright E2E tests for frontend"

# Install system dependencies for Playwright
RUN apk add --no-cache \
    libc6-compat

# Set environment
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PUPPETEER_EXECUTABLE_PATH=/ms-playwright/chromium-*/chrome-linux/chrome
ENV CI=true

WORKDIR /app/listpkgs.nuros.front-end

# Install pnpm
RUN corepack enable pnpm && pnpm --version

# Copy package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile --prefer-offline

# Install Playwright browsers
RUN pnpm exec playwright install chromium --with-deps

# Copy source code (AFTER dependencies so they're in the image layer)
COPY listpkgs.nuros.front-end/ .

# Copy public assets (repodata.json if exists)
# Using RUN to avoid build failure if file doesn't exist
RUN if [ -f public/repodata.json ]; then cp public/repodata.json public/repodata.json.bak; fi || true

# Run tests
CMD ["pnpm", "test"]
