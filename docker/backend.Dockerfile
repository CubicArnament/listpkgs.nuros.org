# =============================================================================
# Backend Dockerfile - Python listpkgs-aggregator
# =============================================================================
# Python environment for package list generation.
# Uses uv package manager for fast dependency installation.
#
# Usage:
#   docker build -f docker/backend.Dockerfile -t nuros-backend .
# =============================================================================

# Use Python 3.12 slim image
FROM python:3.12-slim

LABEL maintainer="NurOS Development Team"
LABEL description="Python environment for listpkgs-aggregator"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set environment variables
ENV PATH="/root/.local/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Copy .ci directory
COPY .ci/ .ci/

# Install uv dependencies (creates .venv)
RUN cd .ci && uv sync --frozen

# Add venv bin to PATH for runtime
ENV PATH="/app/.ci/.venv/bin:$PATH"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

# Default command
CMD ["tail", "-f", "/dev/null"]
