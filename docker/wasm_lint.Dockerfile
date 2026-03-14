# =============================================================================
# WASM Lint Dockerfile - golangci-lint
# =============================================================================
# Runs Go linters on WASM source code.
# Uses golangci-lint for comprehensive linting.
#
# Usage:
#   docker build -f docker/wasm_lint.Dockerfile -t nuros-wasm-lint .
# =============================================================================

# Use Go official image
FROM golang:1.21-alpine

LABEL maintainer="NurOS Development Team"
LABEL description="WASM linting environment with golangci-lint"

# Install system dependencies
RUN apk add --no-cache \
    git \
    make

# Install golangci-lint
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

WORKDIR /workspace

# Copy Go module files
COPY listpkgs.nuros.front-end/src-go/go.mod ./listpkgs.nuros.front-end/src-go/go.mod
COPY listpkgs.nuros.front-end/src-go/go.sum ./listpkgs.nuros.front-end/src-go/go.sum 2>/dev/null || true

# Download dependencies
RUN cd listpkgs.nuros.front-end/src-go && go mod download || true

# Copy source code
COPY listpkgs.nuros.front-end/src-go/ ./listpkgs.nuros.front-end/src-go/
COPY listpkgs.nuros.front-end/src-go/.golangci.yml ./listpkgs.nuros.front-end/src-go/.golangci.yml

WORKDIR /workspace/listpkgs.nuros.front-end/src-go

# Run linter
CMD ["sh", "-c", "golangci-lint run --config .golangci.yml ./..."]
