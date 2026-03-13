# =============================================================================
# Code Formatter Dockerfile - Python + Frontend
# =============================================================================
# Unified formatter for both Python backend and frontend code.
# Uses black + isort for Python, prettier for TS/TSX/SCSS/CSS.
#
# Usage:
#   docker build -f docker/formatter.Dockerfile -t nuros-formatter .
#   docker run --rm -v $(pwd):/workspace nuros-formatter
# =============================================================================

FROM python:3.12-slim AS python-formatter

LABEL maintainer="NurOS Development Team"
LABEL description="Code formatter for Python and Frontend"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python formatters
RUN uv pip install black isort

# =============================================================================

FROM node:22-alpine AS frontend-formatter

LABEL maintainer="NurOS Development Team"
LABEL description="Prettier formatter for frontend code"

# Install pnpm
RUN corepack enable pnpm && pnpm --version

WORKDIR /app/listpkgs.nuros.front-end

# Copy package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile --prefer-offline

# =============================================================================

FROM python:3.12-slim AS final

LABEL maintainer="NurOS Development Team"
LABEL description="Unified code formatter"

# Install git and curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python formatters
RUN uv pip install black isort

# Install pnpm
RUN curl -fsSL https://get.pnpm.io/v6.js | node - add --global pnpm

WORKDIR /workspace

# Copy frontend package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml /workspace/listpkgs.nuros.front-end/

# Install frontend dependencies
RUN cd /workspace/listpkgs.nuros.front-end && pnpm install --frozen-lockfile --prefer-offline

# Copy source code
COPY .ci/ /workspace/.ci/
COPY listpkgs.nuros.front-end/ /workspace/listpkgs.nuros.front-end/

WORKDIR /workspace

# Format command
CMD ["sh", "-c", "\
    echo '🔧 Formatting Python code...' && \
    black --config .ci/pyproject.toml .ci/ && \
    isort .ci/ && \
    echo '🎨 Formatting frontend code...' && \
    cd listpkgs.nuros.front-end && pnpm format && \
    echo '✅ Formatting complete!' \
"]
