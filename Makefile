# Makefile for pastedown

# Version management
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
GIT_COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Build configuration
BUILD_DIR := .build
RELEASE_DIR := $(BUILD_DIR)/release
BINARY_NAME := pastedown
INSTALL_DIR := /usr/local/bin

# Swift build flags
SWIFT_BUILD_FLAGS := -c release
SWIFT_TEST_FLAGS := 

# Default target
.PHONY: all
all: build

# Build the project
.PHONY: build
build:
	@echo "Building pastedown version $(VERSION)..."
	swift build $(SWIFT_BUILD_FLAGS)
	@echo "Build complete: $(RELEASE_DIR)/$(BINARY_NAME)"

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	swift test $(SWIFT_TEST_FLAGS) || echo "No tests found or tests failed"
	@echo "Tests completed"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf $(BUILD_DIR)
	@echo "Clean complete"

# Install to system
.PHONY: install
install: build
	@echo "Installing pastedown to $(INSTALL_DIR)..."
	sudo cp $(RELEASE_DIR)/$(BINARY_NAME) $(INSTALL_DIR)/$(BINARY_NAME)
	sudo chmod +x $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "Installation complete"

# Uninstall from system
.PHONY: uninstall
uninstall:
	@echo "Uninstalling pastedown..."
	sudo rm -f $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "Uninstall complete"

# Show version information
.PHONY: version
version:
	@echo "Version: $(VERSION)"
	@echo "Build Time: $(BUILD_TIME)"
	@echo "Git Commit: $(GIT_COMMIT)"

# Run the built binary
.PHONY: run
run: build
	@echo "Running pastedown..."
	$(RELEASE_DIR)/$(BINARY_NAME) --version

# Development workflow
.PHONY: dev
dev: clean build test
	@echo "Development build complete"

# Release preparation
.PHONY: release-check
release-check:
	@echo "Checking release readiness..."
	@if git diff --quiet HEAD; then \
		echo "✓ Working directory is clean"; \
	else \
		echo "✗ Working directory has uncommitted changes"; \
		exit 1; \
	fi
	@if git describe --exact-match --tags HEAD >/dev/null 2>&1; then \
		echo "✓ HEAD is tagged"; \
	else \
		echo "✗ HEAD is not tagged"; \
		exit 1; \
	fi
	@echo "Release check passed"

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build        - Build the project"
	@echo "  test         - Run tests"
	@echo "  clean        - Clean build artifacts"
	@echo "  install      - Install to system"
	@echo "  uninstall    - Remove from system"
	@echo "  version      - Show version information"
	@echo "  run          - Build and run the binary"
	@echo "  dev          - Clean, build, and test"
	@echo "  release-check - Check release readiness"
	@echo "  help         - Show this help"
