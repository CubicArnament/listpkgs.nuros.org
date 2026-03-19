# =============================================================================
# Frontend Development Dockerfile
# =============================================================================
# Node.js 24 Alpine with pnpm
# Optimized for hot-reload with Vite
# =============================================================================

FROM node:24-alpine

WORKDIR /app/listpkgs.nuros.front-end

# Copy package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml ./

# Install dependencies (without frozen-lockfile due to pnpm version differences)
RUN corepack enable pnpm && pnpm install

# Expose Vite dev server port
EXPOSE 5173

# Default command - will be overridden in docker-compose
CMD ["pnpm", "dev"]
