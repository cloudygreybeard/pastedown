# Contributing to pastedown

Thank you for your interest in contributing to pastedown!

## Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/pastedown.git
   cd pastedown
   ```
3. Build the project:
   ```bash
   swift build
   ```
4. Run tests:
   ```bash
   swift test
   ```

## Creating Releases

Use the release script to create new versions:

```bash
# Create a new release
./hack/release.sh 0.1.0
```

## Making Changes

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make your changes
3. Test your changes:
   ```bash
   swift build
   swift test
   ```
4. Commit your changes:
   ```bash
   git commit -m "Add your feature"
   ```
5. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

## Submitting a Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your feature branch
4. Fill out the pull request template
5. Submit the pull request

## Code Style

- Follow Swift naming conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small

## Testing

- Add tests for new features
- Ensure all tests pass before submitting
- Test on macOS 13.0+ with Swift 6.2+

## License

By contributing to pastedown, you agree that your contributions will be licensed under the Apache License 2.0.
