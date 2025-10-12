# Development Guide

This guide is for developers who want to build, test, and contribute to this library.

## Table of Contents

- [Quick Start](#quick-start)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Building](#building)
- [Testing](#testing)
- [Documentation](#documentation)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

```bash
# 1. Install required Rust targets
./scripts/setup.sh

# 2. Build for all platforms
./scripts/build-all.sh

# 3. Run all tests
./scripts/test-all.sh

# 4. Generate documentation
./scripts/doc-all.sh
```

---

## Development Setup

### Prerequisites

- **Rust** (stable): Install from [rustup.rs](https://rustup.rs/)
- **Xcode** (for iOS/macOS): Install from Mac App Store
- **Android NDK** (for Android): Set `NDK_HOME` environment variable
- **Jazzy** (optional, for Swift docs): `gem install jazzy`
- **Gradle** (optional, for Kotlin): Included via wrapper or install separately

### Initial Setup

Run the setup script to install all required Rust compilation targets:

```bash
./scripts/setup.sh
```

This installs targets for:
- iOS (device + simulator)
- macOS (Apple Silicon)
- Android (all architectures)
- Linux, Windows, WebAssembly

---

## Project Structure

```
.
├── src/                          # Rust source code
│   ├── lib.rs                    # Library entry point
│   ├── template.rs               # Core implementation
│   ├── uniffi_wrapper.rs         # UniFFI bindings
│   └── error.rs                  # Error types
├── tests/                        # Rust integration tests
│   └── template_tests.rs
├── platforms/
│   ├── apple/                    # iOS/macOS Swift package
│   │   ├── Package.swift
│   │   ├── Sources/Template/     # Generated Swift bindings
│   │   └── Tests/TemplateTests/  # Swift tests
│   └── kotlin/                   # Android/JVM Kotlin project
│       ├── build.gradle.kts
│       ├── src/commonMain/       # Generated Kotlin bindings
│       └── src/commonTest/       # Kotlin tests
├── scripts/                      # Build, test, and documentation scripts
│   ├── build-all.sh              # Build for all platforms
│   ├── build-apple.sh            # Build iOS/macOS
│   ├── build-kotlin.sh           # Build Android/JVM
│   ├── test-all.sh               # Run all tests
│   ├── test-apple.sh             # Test iOS/macOS
│   ├── test-kotlin.sh            # Test Android/JVM
│   ├── doc-all.sh                # Generate documentation
│   └── setup.sh                  # Install Rust targets
└── Cargo.toml                    # Rust configuration
```

### Architecture

This library uses **UniFFI** to generate language bindings:

1. **Rust Core** (`src/template.rs`): Pure Rust implementation
2. **UniFFI Wrapper** (`src/uniffi_wrapper.rs`): Exports functions with `#[uniffi::export]`
3. **Generated Bindings**: Build scripts generate Swift/Kotlin code automatically

---

## Building

### Build All Platforms

```bash
./scripts/build-all.sh
```

This builds:
- iOS (arm64 device + simulators)
- macOS (Apple Silicon)
- Android (all architectures)
- JVM (macOS/Linux)

### Build Specific Platforms

```bash
./scripts/build-apple.sh    # iOS + macOS only
./scripts/build-kotlin.sh   # Android + JVM only
cargo build                 # Rust library only
```

### Build Outputs

- **iOS/macOS**: `platforms/apple/xcframework/librust_multiplatform_template_lib.xcframework`
- **Android**: `platforms/kotlin/src/jniLibs/{arch}/librust_multiplatform_template_lib.so`
- **JVM**: `platforms/kotlin/src/jvmMain/kotlin/librust_multiplatform_template_lib.dylib`

### Build Options

For release builds with optimizations, the scripts use `--release` by default. For debug builds:

```bash
cargo build --target aarch64-apple-ios
```

---

## Testing

### Run All Tests

```bash
./scripts/test-all.sh
```

This runs:
- Rust unit tests
- Rust integration tests
- Rust doc tests
- Swift tests (iOS/macOS)
- Kotlin tests (Android/JVM, if Gradle available)

### Run Specific Test Suites

```bash
cargo test                      # Rust tests only
./scripts/test-apple.sh         # Swift tests only
./scripts/test-kotlin.sh        # Kotlin tests only
```

### Writing Tests

#### Rust Tests

Add integration tests in `tests/template_tests.rs`:

```rust
use rust_multiplatform_template_lib::{hello_world, echo};

#[test]
fn test_your_feature() {
    assert!(hello_world());
    let result = echo("test".to_string()).unwrap();
    assert_eq!(result, Some("test".to_string()));
}
```

#### Swift Tests

Edit `platforms/apple/Tests/TemplateTests/TemplateTests.swift`:

```swift
func testYourFeature() throws {
    XCTAssertTrue(helloWorld())
    let result = try echo(input: "test")
    XCTAssertEqual(result, "test")
}
```

#### Kotlin Tests

Edit `platforms/kotlin/src/commonTest/kotlin/TemplateTest.kt`:

```kotlin
@Test
fun testYourFeature() {
    assertTrue(helloWorld())
    assertEquals("test", echo("test"))
}
```

---

## Documentation

### Generate All Documentation

```bash
./scripts/doc-all.sh
```

Generates:
- **Rust**: `docs/lib/` (using `cargo doc`)

### View Documentation Locally

```bash
# macOS
open docs/lib/index.html

# Linux
xdg-open docs/lib/index.html

# Or start a local server
cd docs && python3 -m http.server 8000
# Open http://localhost:8000/lib/
```

### Publishing Documentation

The recommended approach is **GitHub Pages**:

1. Generate docs: `./scripts/doc-all.sh`
2. Commit: `git add docs/ && git commit -m "Update docs"`
3. Push: `git push`
4. Enable GitHub Pages in repository settings (source: `/docs`)

### Writing Documentation

Add documentation to your Rust code:

```rust
/// Brief description of function
///
/// More detailed explanation...
///
/// # Arguments
/// * `input` - Description of parameter
///
/// # Returns
/// Description of return value
///
/// # Errors
/// When this function can fail
///
/// # Example
/// ```
/// use your_lib::your_function;
/// let result = your_function("test");
/// ```
pub fn your_function(input: String) -> Result<String, Error> {
    // implementation
}
```

---

## Customization

### Adding New Functions

1. **Add to Rust** (`src/template.rs`):
```rust
pub fn new_function(param: String) -> i32 {
    param.len() as i32
}
```

2. **Expose via UniFFI** (`src/uniffi_wrapper.rs`):
```rust
#[uniffi::export]
pub fn new_function(param: String) -> i32 {
    template::new_function(param)
}
```

3. **Rebuild**:
```bash
./scripts/build-all.sh
```

The Swift and Kotlin bindings are generated automatically!

### Working with Complex Types

#### Structs/Records

```rust
// In uniffi_wrapper.rs
#[derive(uniffi::Record)]
pub struct Person {
    pub name: String,
    pub age: u32,
}

#[uniffi::export]
pub fn create_person(name: String, age: u32) -> Person {
    Person { name, age }
}
```

#### Enums

```rust
#[derive(uniffi::Enum)]
pub enum Status {
    Active,
    Inactive,
}

#[uniffi::export]
pub fn get_status() -> Status {
    Status::Active
}
```

#### Error Handling

```rust
#[derive(Debug, thiserror::Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum MyError {
    #[error("Invalid input: {message}")]
    InvalidInput { message: String },
}

#[uniffi::export]
pub fn risky_function(value: i32) -> Result<String, MyError> {
    if value < 0 {
        Err(MyError::InvalidInput {
            message: "Must be positive".to_string()
        })
    } else {
        Ok(format!("Success: {}", value))
    }
}
```

### Renaming the Library

To rename from `rust-multiplatform-template-lib` to your own name:

1. **Cargo.toml**: Change `name = "your-library-name"`
2. **Package.swift**: Update all occurrences of `Template`
3. **build.gradle.kts**: Update `group` and `rootProject.name`
4. **Build scripts**: Replace `librust_multiplatform_template_lib` with `libyour_library_name`
5. Rename directories in `platforms/apple/Sources/` and `platforms/apple/Tests/`

### Adding Dependencies

Add to `Cargo.toml`:

```toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

Dependencies used in public APIs must be converted to UniFFI-compatible types.

---

## Troubleshooting

### Build Issues

**Problem**: Target not installed
```
error: can't find crate for `core`
```

**Solution**: Run setup script
```bash
./scripts/setup.sh
```

---

**Problem**: UniFFI bindings not generated
```
error: cannot find rust_multiplatform_template_lib in scope
```

**Solution**: The bindings are generated during build. Clean and rebuild:
```bash
cargo clean
./scripts/build-all.sh
```

---

**Problem**: Android NDK not found
```
error: linker `aarch64-linux-android21-clang` not found
```

**Solution**: Set `NDK_HOME`:
```bash
export NDK_HOME=$ANDROID_HOME/ndk/29.0.13846066
```

### Test Issues

**Problem**: Swift tests fail with module not found

**Solution**: Build first, then test:
```bash
./scripts/build-apple.sh
./scripts/test-apple.sh
```

---

**Problem**: Gradle not found for Kotlin tests

**Solution**: Tests will be gracefully skipped. To run them:
1. Install Gradle, or
2. Use the Gradle wrapper (if available in `platforms/kotlin/`)

### Documentation Issues

**Problem**: Jazzy errors when generating Swift docs

**Solution**: Swift bindings are auto-generated by UniFFI. The main documentation is in Rust docs (`docs/rust/`), which always generates successfully. Swift/Kotlin docs are optional.

---

## Development Workflow

Recommended workflow for making changes:

1. **Make changes** to Rust code in `src/`
2. **Add tests** in `tests/` (Rust) and platform-specific test files
3. **Run tests**: `./scripts/test-all.sh`
4. **Build all platforms**: `./scripts/build-all.sh`
5. **Generate docs**: `./scripts/doc-all.sh`
6. **Commit changes**

### Before Committing

```bash
# Format code
cargo fmt

# Check for issues
cargo clippy

# Run all tests
./scripts/test-all.sh

# Ensure builds succeed
./scripts/build-all.sh
```

---

## Additional Resources

- [UniFFI Documentation](https://mozilla.github.io/uniffi-rs/)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform.html)
- [Cargo Book](https://doc.rust-lang.org/cargo/)

---

## Contributing

When contributing to this library:

1. Follow the existing code style
2. Add tests for new functionality
3. Update documentation
4. Ensure all tests pass
5. Run `cargo fmt` and `cargo clippy`

---

**Happy coding! 🦀📱💻**
