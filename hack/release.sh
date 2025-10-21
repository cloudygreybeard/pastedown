#!/bin/bash

# Release script for pastedown
# Usage: ./hack/release.sh <version>
# Example: ./hack/release.sh 0.1.0

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.1.0"
    exit 1
fi

VERSION=$1
TAG="v${VERSION}"

echo "Creating release for version ${VERSION}"

# Check if tag already exists
if git rev-parse "${TAG}" >/dev/null 2>&1; then
    echo "Tag ${TAG} already exists"
    exit 1
fi

# Check working directory is clean
if ! git diff --quiet HEAD; then
    echo "Working directory has uncommitted changes"
    echo "Please commit or stash changes before creating a release"
    exit 1
fi

# Build and test using Makefile
echo "Building and testing..."
make dev

# Show version info
echo "Version information:"
make version

# Create tag
echo "Creating tag ${TAG}"
git tag -a "${TAG}" -m "Release ${VERSION}"

# Push tag
echo "Pushing tag ${TAG}"
git push origin "${TAG}"

echo "Release ${VERSION} created successfully!"
echo "GitHub Actions will now build and release the binary."
echo "Homebrew formula will be generated automatically."
