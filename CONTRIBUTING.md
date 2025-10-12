# Contributing to Rust Multiplatform Template Library

Thank you for your interest in contributing to this project! We welcome contributions from everyone.

## Table of Contents

- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Getting Help](#getting-help)

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs **actual behavior**
- **Environment details** (OS, Rust version, platform)
- **Code samples** or test cases if applicable

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description** of the enhancement
- **Use cases** and why this enhancement would be useful
- **Possible implementation** approach (if you have ideas)

### Pull Requests

We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`
2. Add tests for any new functionality
3. Ensure the test suite passes (`./scripts/test-all.sh`)
4. Update documentation as needed
5. Follow the coding standards below
6. Submit your pull request!

## Development Setup

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed setup instructions. Quick start:

```bash
# Install Rust targets
./scripts/setup.sh

# Build all platforms
./scripts/build-all.sh

# Run tests
./scripts/test-all.sh
```

### Prerequisites

- **Rust** (stable) - Install from [rustup.rs](https://rustup.rs/)
- **Xcode** (for iOS/macOS)
- **Android NDK** (for Android)

## Pull Request Process

1. **Update documentation** - If you change APIs, update the relevant docs
2. **Add tests** - All new functionality should have tests
3. **Run the full test suite** - `./scripts/test-all.sh` must pass
4. **Format your code** - Run `cargo fmt` before committing
5. **Check for issues** - Run `cargo clippy` and fix any warnings
6. **Update CHANGELOG.md** - Add a note about your changes under "Unreleased"
7. **Descriptive PR title** - Use present tense ("Add feature" not "Added feature")
8. **Reference issues** - Link related issues in the PR description

### Review Process

- At least one maintainer must approve the PR
- All CI checks must pass
- Changes may be requested before merging
- Once approved, a maintainer will merge your PR

## Coding Standards

### Rust Code

- Follow the [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- Use `cargo fmt` for formatting (adheres to rustfmt defaults)
- Use `cargo clippy` and address all warnings
- Write idiomatic Rust code
- Add doc comments (`///`) for all public APIs
- Include examples in doc comments where helpful

### Example of Good Documentation

```rust
/// Processes the input string and returns a modified version.
///
/// # Arguments
///
/// * `input` - The string to process
///
/// # Returns
///
/// Returns `Some(String)` if the input is non-empty, `None` otherwise.
///
/// # Examples
///
/// ```
/// use rust_multiplatform_template_lib::echo;
///
/// let result = echo("hello".to_string()).unwrap();
/// assert_eq!(result, Some("hello".to_string()));
/// ```
pub fn echo(input: String) -> Result<Option<String>, TemplateError> {
    // implementation
}
```

### Tests

- Unit tests should be in the same file as the code they test
- Integration tests go in the `tests/` directory
- Test all edge cases and error conditions
- Use descriptive test names: `test_echo_returns_none_for_empty_string`

### Shell Scripts

- Use `#!/bin/bash` and `set -e` for error handling
- Add descriptive comments
- Follow existing script style in `scripts/` directory

## Commit Message Guidelines

We follow conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, missing semi-colons, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Changes to build process, tools, or dependencies

### Examples

```
feat(android): add support for arm64-v8a architecture

Added build configuration and targets for Android arm64-v8a.
This allows the library to run on modern 64-bit Android devices.

Closes #42
```

```
fix(ios): resolve memory leak in Swift bindings

The Swift bindings were not properly releasing Rust objects,
causing memory leaks in iOS applications.

Fixes #38
```

```
docs: update README with Windows build instructions

Added detailed steps for building on Windows with MSVC toolchain.
```

## Getting Help

- **Documentation**: Start with [README.md](README.md) and [DEVELOPMENT.md](DEVELOPMENT.md)
- **Issues**: Search [existing issues](https://github.com/eaceto/rust-multiplatform-template-lib/issues)
- **Discussions**: Use [GitHub Discussions](https://github.com/eaceto/rust-multiplatform-template-lib/discussions) for questions
- **Contact**: Reach out to [Ezequiel (Kimi) Aceto](mailto:eaceto@pm.me)

## Project Structure

Understanding the project structure will help you contribute:

```
├── src/                    # Rust source code
│   ├── lib.rs             # Library entry point
│   ├── template.rs        # Core implementation
│   └── uniffi_wrapper.rs  # UniFFI bindings
├── tests/                 # Rust integration tests
├── platforms/
│   ├── apple/             # iOS/macOS Swift package
│   └── kotlin/            # Android/JVM Kotlin package
├── scripts/               # Build, test, and documentation scripts
└── docs/                  # Generated documentation
```

## License

By contributing, you agree that your contributions will be licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

Thank you for contributing! 🦀📱💻
