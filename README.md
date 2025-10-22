# pastedown

macOS Pasteboard to Markdown

pastedown converts formatted text from the macOS pasteboard to Markdown format. It reads HTML, RTF, and plain text from the pasteboard and converts them to clean Markdown while preserving formatting, links, lists, and other structural elements.

The tool provides fine-grained control over source selection, content merging, and output formatting. It supports debugging and analysis features to help users understand what content is available in the pasteboard and how it will be converted.

## Installation

### Homebrew (Recommended)

Install using Homebrew with automatic tap management:

```bash
brew install cloudygreybeard/tap/pastedown
```

This command automatically taps the repository and installs the universal binary (supports both Intel and Apple Silicon Macs). The tap is maintained at [cloudygreybeard/homebrew-tap](https://github.com/cloudygreybeard/homebrew-tap).

### Binary Download

Download the latest release binary from [GitHub Releases](https://github.com/cloudygreybeard/pastedown/releases):

```bash
# Download and install
curl -L https://github.com/cloudygreybeard/pastedown/releases/latest/download/pastedown -o /usr/local/bin/pastedown
chmod +x /usr/local/bin/pastedown
```

## Basic Usage

```bash
# Convert pasteboard to Markdown
pastedown

# Save to file
pastedown > output.md

# Inspect pasteboard contents
pastedown inspect
```

## Features

### Source Selection

Control which pasteboard format to use for conversion:

```bash
# Force specific source type
pastedown --from html
pastedown --from rtf
pastedown --from text
pastedown --from attributed

# Set custom priority order
pastedown --priority rtf,html,text
pastedown --priority text,html
```

### Content Merging

Combine multiple pasteboard formats:

```bash
# Merge HTML and text content
pastedown --merge html,text

# Merge with custom separator
pastedown --merge html,text --separator "\n---\n"

# Merge all available formats
pastedown --merge html,rtf,text
```

### Debugging and Analysis

```bash
# Show all available conversions
pastedown --all

# Inspect pasteboard in plain text
pastedown inspect

# Inspect pasteboard in JSON format
pastedown inspect --output json
```

## Use Cases

### Content Conversion

Convert formatted text from web browsers, word processors, or rich text editors:

```bash
# Basic conversion (HTML preferred)
pastedown

# Force plain text output
pastedown --from text

# Prefer RTF over HTML
pastedown --priority rtf,html,text
```

### Content Analysis

Debug conversion issues or analyze pasteboard contents:

```bash
# See all available formats and conversions
pastedown --all

# Inspect what's in the pasteboard
pastedown inspect

# Get structured data for scripting
pastedown inspect --output json | jq '.source.html.content'
```

### Content Merging

Combine multiple sources of information:

```bash
# Merge rich and plain text versions
pastedown --merge html,text

# Create document with clear separations
pastedown --merge html,text --separator "\n\n---\n\n"
```

## Output Formats

### Plain Text (Default)

```bash
pastedown
pastedown inspect
```

### JSON

```bash
pastedown inspect --output json
```

JSON output includes:
- Source formats available (`html`, `rtf`, `text`, `attributedString`)
- Content and metadata for each format
- Target markdown conversion with source tracking

## Requirements

- macOS 13.0+
- Swift 5.9+ (Command Line Tools for Xcode)

## Development

### Building from Source

```bash
git clone https://github.com/cloudygreybeard/pastedown.git
cd pastedown
make build
make install
```

**Note**: Building from source requires Swift 5.9+ and Command Line Tools for Xcode.

### Development Workflow

```bash
# Clean, build, and test
make dev

# Show version information
make version

# Run the built binary
make run
```

### Creating Releases

```bash
# Create a new release
./hack/release.sh 0.1.0
```

### Available Make Targets

```bash
make help          # Show all available targets
make build         # Build the project
make test          # Run tests
make clean         # Clean build artifacts
make install       # Install to system
make uninstall     # Remove from system
make version       # Show version information
make run           # Build and run the binary
make dev           # Clean, build, and test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

Apache 2.0