# =============================================================================
# Backend Dockerfile - Python environment for listpkgs-aggregator
# =============================================================================

# Use Python 3.12 slim image
FROM python:3.12-slim

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

# Install the package and dependencies using uv
RUN cd .ci && uv sync --frozen

# Make the command available
RUN ln -s /app/.ci/.venv/bin/listpkgs-aggregate /usr/local/bin/listpkgs-aggregate

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

# Default command - keep container alive for development
CMD ["tail", "-f", "/dev/null"]
