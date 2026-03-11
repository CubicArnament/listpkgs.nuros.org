# Local Development Container
# Provides complete development environment with hot reload
# Does NOT build/bundle - running with HMR via compose

FROM node:22-alpine

LABEL maintainer="NurOS Development Team"
LABEL description="Local development container with pnpm, tools, and nginx"

# Install dependencies for dev
RUN apk add --no-cache \
    pnpm \
    git \
    curl \
    bash \
    vim \
    nginx \
    supervisor \
    tini

# Set environment
ENV NODE_ENV=development
ENV PNPM_HOME="/root/.pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Create app directory
WORKDIR /workspace

# Copy package files (will be mounted in compose but keep for layer caching)
COPY package.json pnpm-lock.yaml ./

# Install global utilities
RUN pnpm install -g @nestjs/cli

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Use tini for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start supervisord to manage nginx + dev server
CMD ["supervisord", "-c", "/workspace/docker/local/supervisord.conf"]
