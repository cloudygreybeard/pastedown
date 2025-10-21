# Homebrew Tap Setup

This document explains how to set up a Homebrew tap for pastedown.

## Creating the Tap

1. Create a new repository named `homebrew-pastedown`:
   ```bash
   # Create the repository on GitHub first, then:
   git clone https://github.com/cloudygreybeard/homebrew-pastedown.git
   cd homebrew-pastedown
   ```

2. The repository structure should be:
   ```
   homebrew-pastedown/
   ├── Formula/
   │   └── pastedown.rb
   └── README.md
   ```

3. Copy the generated formula from the GitHub Actions artifact to `Formula/pastedown.rb`

## Release Process

The release process is automated:

1. Create a release using the hack script:
   ```bash
   ./hack/release.sh 0.1.0
   ```

2. GitHub Actions will automatically:
   - Build the binary
   - Create a GitHub release
   - Generate the Homebrew formula
   - Calculate SHA256 checksums

## Installing from the Tap

Users can install pastedown from the tap:

```bash
# Add the tap
brew tap cloudygreybeard/pastedown

# Install pastedown
brew install pastedown
```

## Updating the Formula

The GitHub Actions workflow automatically generates updated formulas for each release. The formula includes:

- Binary download from GitHub Releases
- SHA256 checksum for security
- Proper dependencies and metadata
- Test verification

## Future: Upstream Homebrew

To submit pastedown to the official Homebrew repository:

1. Ensure the project meets Homebrew requirements:
   - Stable releases with semantic versioning
   - Good test coverage
   - Active maintenance
   - Clear documentation

2. Create a pull request to homebrew-core:
   ```bash
   brew create https://github.com/cloudygreybeard/pastedown
   ```

3. Follow Homebrew's contribution guidelines for formula submission.
