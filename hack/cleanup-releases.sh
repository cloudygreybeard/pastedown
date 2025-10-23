#!/bin/bash
# Clean up old releases and tags from the pastedown repository

set -e

REPO="cloudygreybeard/pastedown"

# Versions to keep (earliest and latest patch version within each minor version)
KEEP_VERSIONS=("v0.1.0" "v0.1.5" "v0.2.0" "v0.2.3" "v0.3.0")

# All existing versions
ALL_VERSIONS=("v0.1.0" "v0.1.1" "v0.1.2" "v0.1.3" "v0.1.4" "v0.1.5" "v0.2.0" "v0.2.1" "v0.2.2" "v0.2.3" "v0.3.0")

echo "Cleaning up releases and tags for $REPO..."
echo "Strategy: Keep earliest and latest patch version within each minor version"
echo ""
echo "Keeping: ${KEEP_VERSIONS[@]}"
echo ""

for version in "${ALL_VERSIONS[@]}"; do
    # Check if this version should be kept
    if [[ " ${KEEP_VERSIONS[@]} " =~ " ${version} " ]]; then
        echo "✓ Keeping $version"
        continue
    fi
    
    echo "Deleting $version..."
    
    # Delete the GitHub release
    gh release delete "$version" --repo "$REPO" --yes 2>/dev/null || echo "  (release already deleted or doesn't exist)"
    
    # Delete the remote tag
    git push --delete origin "$version" 2>/dev/null || echo "  (remote tag already deleted or doesn't exist)"
    
    # Delete the local tag
    git tag -d "$version" 2>/dev/null || echo "  (local tag already deleted or doesn't exist)"
    
    echo "✓ Deleted $version"
    echo ""
done

echo ""
echo "Cleanup complete!"
echo ""
echo "Remaining releases:"
gh release list --repo "$REPO"

echo ""
echo "Remaining tags:"
git tag
