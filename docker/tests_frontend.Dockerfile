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

# Install system dependencies
RUN apk add --no-cache \
    libc6-compat \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Set environment
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV CI=true

WORKDIR /app

# Install pnpm
RUN corepack enable pnpm && pnpm --version

# Copy package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile --prefer-offline

# Copy source code
COPY listpkgs.nuros.front-end/ ./listpkgs.nuros.front-end/

# Copy public assets (repodata.json if exists)
COPY --chown=node:node listpkgs.nuros.front-end/public/repodata.json ./listpkgs.nuros.front-end/public/repodata.json 2>/dev/null || true

WORKDIR /app/listpkgs.nuros.front-end

# Run tests
CMD ["pnpm", "test"]
