# =============================================================================
# Frontend Lint Dockerfile - ESLint + Stylelint
# =============================================================================
# Lightweight container for code linting.
# Does NOT build the frontend - only runs linting checks.
#
# Usage:
#   docker build -f docker/lint_frontend.Dockerfile -t nuros-frontend-lint .
# =============================================================================

FROM node:22-alpine

LABEL maintainer="NurOS Development Team"
LABEL description="ESLint and Stylelint for frontend code"

# Install minimal dependencies
RUN apk add --no-cache libc6-compat

# Install pnpm
RUN corepack enable pnpm && pnpm --version

WORKDIR /app/listpkgs.nuros.front-end

# Copy package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml ./

# Install dependencies (BEFORE source code so they're in the image layer)
RUN pnpm install --frozen-lockfile --prefer-offline

# Copy source code (AFTER dependencies)
COPY listpkgs.nuros.front-end/ .

# Set CI environment variable
ENV CI=true

# Default command - run both linters with --fix
CMD ["sh", "-c", "pnpm lint"]
