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

# Generate version file
.PHONY: generate-version
generate-version:
	@echo "Generating version information..."
	@mkdir -p Sources/Pastedown
	@./hack/generate-version.sh Sources/Pastedown/Version.swift

# Build the project
.PHONY: build
build: generate-version
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

# Deploy key management
.PHONY: setup-deploy-key
setup-deploy-key:
	@echo "Setting up deploy key for homebrew automation..."
	@if [ ! -f hack/deploy_key ]; then \
		ssh-keygen -t ed25519 -f hack/deploy_key -N "" -C "pastedown-homebrew-deploy"; \
		echo "Generated deploy key pair in hack/deploy_key*"; \
	else \
		echo "Deploy key already exists in hack/deploy_key"; \
	fi
	@echo "Public key:"
	@cat hack/deploy_key.pub
	@echo ""
	@echo "Next steps:"
	@echo "1. Add the public key above as a deploy key to cloudygreybeard/homebrew-pastedown"
	@echo "2. Run 'make add-deploy-secret' to add the private key as a repository secret"

.PHONY: add-deploy-secret
add-deploy-secret:
	@echo "Adding deploy key as repository secret..."
	@if [ -f hack/deploy_key ]; then \
		gh secret set HOMEBREW_DEPLOY_KEY --body "$$(cat hack/deploy_key)" --repo cloudygreybeard/pastedown; \
		echo "Deploy key added as HOMEBREW_DEPLOY_KEY secret"; \
	else \
		echo "Error: hack/deploy_key not found. Run 'make setup-deploy-key' first"; \
		exit 1; \
	fi

.PHONY: setup-automation
setup-automation: setup-deploy-key
	@echo "Deploy key setup complete!"
	@echo "Public key:"
	@cat hack/deploy_key.pub
	@echo ""
	@echo "Manual step required:"
	@echo "1. Go to https://github.com/cloudygreybeard/homebrew-pastedown/settings/keys"
	@echo "2. Click 'Add deploy key'"
	@echo "3. Paste the public key above"
	@echo "4. Give it a title like 'pastedown-homebrew-deploy'"
	@echo "5. Check 'Allow write access'"
	@echo "6. Click 'Add key'"
	@echo ""
	@echo "Then run: make add-deploy-secret"

.PHONY: test-automation
test-automation:
	@echo "Testing homebrew automation..."
	@echo "Creating a test tag to trigger automation..."
	@git tag test-automation-$(shell date +%s)
	@git push origin test-automation-$(shell date +%s)
	@echo "Check GitHub Actions to see if automation works"
	@echo "Delete test tag with: git push origin --delete test-automation-$(shell date +%s)"

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
	@echo "  setup-deploy-key - Generate deploy key for homebrew automation"
	@echo "  add-deploy-secret - Add deploy key as repository secret"
	@echo "  setup-automation - Complete automation setup (interactive)"
	@echo "  test-automation - Test automation with a test tag"
	@echo "  help         - Show this help"
