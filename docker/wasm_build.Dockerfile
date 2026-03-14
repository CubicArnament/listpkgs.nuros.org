# =============================================================================
# WASM Build Dockerfile - TinyGo + Meson + Ninja
# =============================================================================
# Builds WebAssembly modules from Go source code.
# Uses TinyGo for compilation with maximum size optimization.
#
# Usage:
#   docker build -f docker/wasm_build.Dockerfile -t nuros-wasm-build .
# =============================================================================

# Use TinyGo official image (includes Go)
FROM tinygo/tinygo:latest

LABEL maintainer="NurOS Development Team"
LABEL description="WASM build environment with TinyGo, Meson, and Ninja"

# Set environment
ENV NODE_ENV=production
ENV CI=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    meson \
    ninja-build \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Go tools
RUN go install golang.org/x/tools/cmd/goimports@latest

WORKDIR /workspace

# Copy Go module files
COPY listpkgs.nuros.front-end/src-go/go.mod ./listpkgs.nuros.front-end/src-go/go.mod

# Download dependencies (if any)
RUN cd listpkgs.nuros.front-end/src-go && go mod download || true

# Copy source code
COPY listpkgs.nuros.front-end/src-go/ ./listpkgs.nuros.front-end/src-go/

WORKDIR /workspace/listpkgs.nuros.front-end/src-go

# Build WASM module with maximum optimization
RUN meson setup build --wipe 2>/dev/null || meson setup build && \
    meson compile -C build && \
    echo "✅ WASM build complete" && \
    ls -lh build/wasm/

# Default command - show build info
CMD ["sh", "-c", "echo 'WASM Build Complete' && ls -lh build/wasm/"]
