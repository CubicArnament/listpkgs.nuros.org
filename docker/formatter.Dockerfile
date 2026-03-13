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

FROM python:3.12-slim AS final

LABEL maintainer="NurOS Development Team"
LABEL description="Unified code formatter"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager) and add to PATH
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install Python formatters (system-wide)
RUN uv pip install --system black isort

# Install pnpm
RUN npm install -g pnpm

WORKDIR /workspace

# Copy frontend package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml /workspace/listpkgs.nuros.front-end/

# Install frontend dependencies (creates node_modules inside listpkgs.nuros.front-end)
RUN cd /workspace/listpkgs.nuros.front-end && pnpm install --frozen-lockfile --prefer-offline

# Verify prettier is installed
RUN ls -la /workspace/listpkgs.nuros.front-end/node_modules/.bin/ | grep prettier || echo "prettier not found"

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
    cd /workspace/listpkgs.nuros.front-end && \
    node_modules/.bin/prettier --write 'src/**/*.{ts,tsx,css,scss}' && \
    echo '✅ Formatting complete!' \
"]
