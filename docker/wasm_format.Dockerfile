# =============================================================================
# WASM Format Dockerfile - gofmt + goimports
# =============================================================================
# Formats Go source code for WASM module.
# Uses gofmt and goimports for consistent code style.
#
# Usage:
#   docker build -f docker/wasm_format.Dockerfile -t nuros-wasm-format .
# =============================================================================

# Use Go official image
FROM golang:1.21-alpine

LABEL maintainer="NurOS Development Team"
LABEL description="WASM formatting environment with gofmt and goimports"

# Install system dependencies
RUN apk add --no-cache \
    git \
    make

# Install goimports
RUN go install golang.org/x/tools/cmd/goimports@latest

WORKDIR /workspace

# Copy source code
COPY listpkgs.nuros.front-end/src-go/ ./listpkgs.nuros.front-end/src-go/

WORKDIR /workspace/listpkgs.nuros.front-end/src-go

# Format code with gofmt and goimports
CMD ["sh", "-c", "\
    echo '📝 Formatting with gofmt...' && \
    gofmt -w -s . && \
    echo '📝 Organizing imports with goimports...' && \
    goimports -w . && \
    echo '✅ Format complete' \
"]
