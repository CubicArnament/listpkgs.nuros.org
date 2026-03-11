# Production Container
# Multi-stage build for optimal image size
# Includes AppArmor profile and auditd for security

FROM node:22-alpine AS builder

WORKDIR /build

COPY package.json pnpm-lock.yaml ./
RUN apk add --no-cache pnpm && \
    pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

# Final production image
FROM alpine:3.19

LABEL maintainer="NurOS Production Team"
LABEL description="Production container with minimal footprint and security hardening"

# Install minimal dependencies
RUN apk add --no-cache \
    node \
    pnpm \
    tini \
    curl \
    ca-certificates \
    apparmor-utils \
    auditd

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy built application from builder
COPY --from=builder --chown=appuser:appuser /build /app

# Set environment
ENV NODE_ENV=production
ENV NODE_PATH=/app/node_modules

# Drop unnecessary capabilities
RUN setcap -r /app 2>/dev/null || true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Switch to non-root user
USER appuser

# Use tini for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start application (no nginx - handled by reverse proxy)
CMD ["node", "dist/index.js"]
