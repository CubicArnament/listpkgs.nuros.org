# WASM Hardware Detector - Makefile
# Для линтинга и форматирования Go кода
# Сборка через Meson + Ninja

.PHONY: all build clean lint format test help

# ============================================================================
# Configuration
# ============================================================================

GO := go
GOFMT := gofmt
GOIMPORTS := goimports
GOLANGCI_LINT := golangci-lint

SRC_DIR := .
BUILD_DIR := build
WASM_DIR := $(BUILD_DIR)/wasm

# Go source files
GO_SOURCES := $(shell find $(SRC_DIR) -name '*.go' -not -path '$(BUILD_DIR)/%')

# ============================================================================
# Main targets
# ============================================================================

all: help

# Сборка через Meson
build:
	@echo "🔨 Building WASM module with Meson..."
	meson setup $(BUILD_DIR) --wipe 2>/dev/null || meson setup $(BUILD_DIR)
	meson compile -C $(BUILD_DIR)
	@echo "✅ WASM build complete: $(WASM_DIR)/hw-detector.wasm"

# Очистка
clean:
	@echo "🧹 Cleaning build directory..."
	rm -rf $(BUILD_DIR)
	@echo "✅ Clean complete"

# ============================================================================
# Linting
# ============================================================================

lint:
	@echo "🔍 Running golangci-lint..."
	@if command -v $(GOLANGCI_LINT) >/dev/null 2>&1; then \
		$(GOLANGCI_LINT) run --config .golangci.yml ./... || true; \
	else \
		echo "⚠️  golangci-lint not found, using go vet"; \
		$(GO) vet ./...; \
	fi
	@echo "✅ Lint complete"

lint-strict:
	@echo "🔍 Running strict golangci-lint..."
	@if command -v $(GOLANGCI_LINT) >/dev/null 2>&1; then \
		$(GOLANGCI_LINT) run --config .golangci.yml --out-format=colored-line-number ./...; \
	else \
		$(GO) vet ./...; \
	fi

# ============================================================================
# Formatting
# ============================================================================

format:
	@echo "📝 Formatting Go code with gofmt..."
	$(GOFMT) -w -s $(SRC_DIR)
	@if command -v $(GOIMPORTS) >/dev/null 2>&1; then \
		echo "📝 Organizing imports with goimports..."; \
		$(GOIMPORTS) -w $(SRC_DIR); \
	fi
	@echo "✅ Format complete"

format-check:
	@echo "🔍 Checking code formatting..."
	@UNFORMATTED=$$($(GOFMT) -l $(SRC_DIR)); \
	if [ -n "$$UNFORMATTED" ]; then \
		echo "❌ Unformatted files:"; \
		echo "$$UNFORMATTED"; \
		exit 1; \
	else \
		echo "✅ All files are formatted"; \
	fi

# ============================================================================
# Testing
# ============================================================================

test:
	@echo "🧪 Running Go tests..."
	$(GO) test -v ./...

test-wasm:
	@echo "🧪 Running WASM tests..."
	tinygo test -target=wasi -v ./...

# ============================================================================
# Development
# ============================================================================

# Запустить всё перед коммитом
pre-commit: format lint-strict test
	@echo "✅ Pre-commit checks passed"

# Полный цикл разработки
dev: clean build lint test
	@echo "✅ Development cycle complete"

# ============================================================================
# Help
# ============================================================================

help:
	@echo "WASM Hardware Detector - Makefile Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build          Сборка WASM модуля через Meson + Ninja"
	@echo "  clean          Очистка build директории"
	@echo "  lint           Линтинг кода (golangci-lint или go vet)"
	@echo "  lint-strict    Строгий линтинг (fail on errors)"
	@echo "  format         Форматирование кода (gofmt + goimports)"
	@echo "  format-check   Проверка форматирования (fail if not formatted)"
	@echo "  test           Запуск Go тестов"
	@echo "  test-wasm      Запуск WASM тестов"
	@echo "  pre-commit     Полный цикл перед коммитом"
	@echo "  dev            Полный цикл разработки"
	@echo "  help           Показать эту справку"
	@echo ""
	@echo "Examples:"
	@echo "  make build     # Собрать WASM модуль"
	@echo "  make lint      # Запустить линтинг"
	@echo "  make format    # Отформатировать код"
	@echo "  make pre-commit # Запустить все проверки перед коммитом"
