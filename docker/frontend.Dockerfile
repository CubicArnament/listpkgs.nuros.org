# =============================================================================
# Frontend Dockerfile - Multi-stage build for development and production
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Dependencies
# -----------------------------------------------------------------------------
FROM node:22-alpine AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

# Install pnpm globally
RUN corepack enable pnpm && pnpm --version

# Copy package files
COPY listpkgs.nuros.front-end/package.json listpkgs.nuros.front-end/pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile --prefer-offline

# -----------------------------------------------------------------------------
# Stage 2: Development
# -----------------------------------------------------------------------------
FROM deps AS dev

WORKDIR /app

# Copy package files
COPY listpkgs.nuros.front-end/ ./listpkgs.nuros.front-end/

# Expose Vite dev server port
EXPOSE 5173

# Set environment for development
ENV NODE_ENV=development
ENV HOST=0.0.0.0

# Start development server
CMD ["pnpm", "--dir", "/app/listpkgs.nuros.front-end", "dev", "--host", "0.0.0.0"]

# -----------------------------------------------------------------------------
# Stage 3: Build
# -----------------------------------------------------------------------------
FROM deps AS builder

WORKDIR /app

# Copy source code
COPY listpkgs.nuros.front-end/ ./listpkgs.nuros.front-end/

# Copy repodata.json if it exists (from update-list step)
COPY --chown=node:node repodata.json ./listpkgs.nuros.front-end/public/repodata.json 2>/dev/null || true

# Set environment for build
ENV NODE_ENV=production

# Build the frontend
RUN cd listpkgs.nuros.front-end && pnpm build

# -----------------------------------------------------------------------------
# Stage 4: Production (nginx)
# -----------------------------------------------------------------------------
FROM nginx:alpine AS production

# Copy custom nginx config
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from builder stage
COPY --from=builder /app/listpkgs.nuros.front-end/dist /usr/share/nginx/html

# Copy repodata.json to nginx
COPY --from=builder /app/listpkgs.nuros.front-end/public/repodata.json /usr/share/nginx/html/ 2>/dev/null || true
COPY --from=builder /app/listpkgs.nuros.front-end/public/repodata.json.sha256 /usr/share/nginx/html/ 2>/dev/null || true

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# -----------------------------------------------------------------------------
# Stage 5: Test (for CI/CD testing)
# -----------------------------------------------------------------------------
FROM deps AS test

WORKDIR /app

# Install Playwright browsers
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Set Playwright browser path
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Copy source code
COPY listpkgs.nuros.front-end/ ./listpkgs.nuros.front-end/

# Copy repodata.json if exists
COPY --chown=node:node repodata.json ./listpkgs.nuros.front-end/public/repodata.json 2>/dev/null || true

WORKDIR /app/listpkgs.nuros.front-end

# Run tests
CMD ["pnpm", "test"]
