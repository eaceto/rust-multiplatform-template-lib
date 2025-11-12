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
- [Best Practices](#best-practices)
- [Version Compatibility Matrix](#version-compatibility-matrix)

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
use rust_multiplatform_template_lib::{random, echo};

#[test]
fn test_your_feature() {
    let result = tokio_test::block_on(async { random().await });
    assert!(result >= 0.0 && result < 1.0);
    assert_eq!(result, Some("test".to_string()));
}
```

#### Swift Tests

Edit `platforms/apple/Tests/TemplateTests/TemplateTests.swift`:

```swift
func testYourFeature() throws {
    let result = try await random()
    XCTAssertTrue(result >= 0.0 && result < 1.0)
    XCTAssertEqual(result, "test")
}
```

#### Kotlin Tests

Edit `platforms/kotlin/src/commonTest/kotlin/TemplateTest.kt`:

```kotlin
@Test
fun testYourFeature() {
    val result = templateRandom()
    assertTrue(result >= 0.0 && result < 1.0)
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

## Best Practices

### FFI Performance Considerations

**Minimize FFI Boundary Crossings**
- Each call across the FFI boundary has overhead (~100-1000ns)
- Batch operations when possible instead of making multiple small calls
- Consider returning collections rather than iterating from Swift/Kotlin

```rust
// Bad: Multiple FFI calls
for i in 0..1000 {
    process_item(i)  // 1000 FFI calls
}

// Good: Single FFI call
process_items_batch(vec![0..1000])  // 1 FFI call
```

**String Handling**
- String conversion (UTF-8 ↔ UTF-16) has cost
- Prefer passing IDs/indices instead of strings when possible
- Cache string lookups on the native side

**Memory Management**
- UniFFI handles memory automatically, but be aware:
  - Large data structures are copied across FFI
  - Use references/handles for large objects when possible
  - Swift: Objects are reference-counted (ARC)
  - Kotlin: Objects are garbage-collected

### Platform-Specific Gotchas

#### iOS/macOS

**Thread Safety**
- Rust functions may be called from any thread
- Use `Arc<Mutex<T>>` or `Arc<RwLock<T>>` for shared mutable state
- UniFFI exports are thread-safe by default

**Memory Warnings**
- Large allocations in Rust aren't visible to iOS memory management
- Monitor memory usage in your app
- Consider implementing cleanup methods for large data structures

**Background Execution**
- Long-running operations should be async
- iOS may terminate background tasks
- Use `Task` in Swift for async Rust calls

#### Android

**ProGuard/R8 Rules**
- If using ProGuard, add rules to keep JNI methods:
```proguard
-keep class uniffi.** { *; }
-keep class template.** { *; }
```

**NDK Version**
- Use NDK r21 or later for best compatibility
- Set minimum API level appropriately (21+ recommended)

**APK Size**
- Including all architectures increases APK size
- Use Android App Bundles for automatic per-device optimization
- Or create separate APKs per architecture

**JNI Threading**
- Rust functions called from Kotlin may run on any thread
- Avoid blocking the main thread with long operations

### Error Handling Best Practices

**Use Result Types**
```rust
// Preferred: Explicit error handling
#[uniffi::export]
pub fn parse_data(input: String) -> Result<Data, MyError> {
    // ...
}
```

**Provide Context in Errors**
```rust
#[derive(Debug, thiserror::Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum MyError {
    #[error("Invalid input: {message} (got: {value})")]
    InvalidInput { message: String, value: String },
}
```

**Handle Panics Gracefully**
- Panics in Rust become exceptions in Swift/Kotlin
- Catch panics in critical paths:
```rust
use std::panic::catch_unwind;

#[uniffi::export]
pub fn safe_operation() -> Result<String, MyError> {
    catch_unwind(|| {
        risky_operation()
    }).map_err(|_| MyError::Panic)?
}
```

### Testing Best Practices

**Test at All Levels**
1. **Rust unit tests**: Test core logic
2. **Rust integration tests**: Test public API
3. **Platform tests**: Test FFI bindings work correctly

**Mock External Dependencies**
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_with_mock() {
        // Test using mock instead of real network/file I/O
    }
}
```

**Test Edge Cases**
- Empty strings/collections
- Very large inputs
- Null/None values
- Concurrent access

### Documentation Best Practices

**Document All Public APIs**
```rust
/// Brief one-line description
///
/// Detailed explanation with examples and edge cases.
///
/// # Arguments
/// * `param` - Description
///
/// # Returns
/// Description of return value
///
/// # Errors
/// * `MyError::InvalidInput` - When input is invalid
///
/// # Example
/// ```
/// let result = my_function("test")?;
/// ```
```

**Keep Examples Up to Date**
- Use `cargo test --doc` to verify doc examples compile

**Document Platform-Specific Behavior**
- Note any differences in iOS vs Android behavior
- Document thread safety guarantees

---

## Version Compatibility Matrix

### Current Versions (Tested)

| Component | Version | Notes |
|-----------|---------|-------|
| **Rust** | 1.83+ | Edition 2021 required |
| **UniFFI** | 0.30.x | Breaking changes between minor versions |
| **Xcode** | 15.0+ | For iOS/macOS builds |
| **iOS Deployment** | 13.0+ | Minimum supported version |
| **macOS Deployment** | 11.0+ | Apple Silicon + Intel |
| **Android NDK** | r21+ (21.0+) | r25+ recommended |
| **Android Min SDK** | 21+ (Android 5.0+) | API Level 21 minimum |
| **Kotlin** | 1.9+ | For Kotlin Multiplatform |
| **Gradle** | 8.0+ | For Android/JVM builds |
| **Java/JVM** | 11+ | For JVM desktop targets |

### Rust Toolchain Compatibility

| Rust Version | UniFFI | Status | Notes |
|--------------|--------|--------|-------|
| 1.83-1.85 | 0.30.x | ✅ Tested | Current stable |
| 1.80-1.82 | 0.30.x | ✅ Compatible | Should work |
| 1.75-1.79 | 0.30.x | ⚠️ May work | Not tested |
| < 1.75 | 0.30.x | ❌ Not supported | Edition 2021 issues |

### Platform SDK Compatibility

#### Apple Platforms

| Xcode | Swift | iOS SDK | macOS SDK | Status |
|-------|-------|---------|-----------|--------|
| 16.x | 6.0 | 18.x | 15.x | ✅ Tested |
| 15.x | 5.9 | 17.x | 14.x | ✅ Tested |
| 14.x | 5.7-5.8 | 16.x | 13.x | ⚠️ Should work |
| < 14.0 | < 5.7 | < 16.0 | < 13.0 | ❌ Not tested |

**Notes:**
- XCFramework requires Xcode 11+
- Swift Package Manager works best with Xcode 14+
- Apple Silicon requires Xcode 12+

#### Android Platform

| NDK Version | Min SDK | Max SDK | Rust Target | Status |
|-------------|---------|---------|-------------|--------|
| r29 (29.x) | 21+ | 35+ | 1.83+ | ✅ Tested |
| r26-r28 | 21+ | 34+ | 1.75+ | ✅ Compatible |
| r25 | 21+ | 33+ | 1.70+ | ⚠️ Should work |
| r21-r24 | 21+ | 30+ | 1.70+ | ⚠️ May work |
| < r21 | - | - | - | ❌ Not supported |

**NDK Architecture Support:**
- `arm64-v8a`: 64-bit ARM (recommended, most devices)
- `armeabi-v7a`: 32-bit ARM (older devices)
- `x86_64`: 64-bit x86 (emulators)
- `x86`: 32-bit x86 (older emulators)

### Dependency Version Pinning

**Critical Dependencies:**

```toml
[dependencies]
uniffi = "0.30"         # Pin minor version - breaking changes common
rand = "0.9"            # Compatible with 0.9.x
thiserror = "2.0"       # Stable, major version updates rare

[build-dependencies]
uniffi = { version = "0.30", features = ["build"] }
```

**Version Update Strategy:**
- **UniFFI**: Test thoroughly before upgrading minor versions
- **Rust**: Keep within 6 months of latest stable
- **Platform SDKs**: Update within 1 year of release

### Known Compatibility Issues

#### UniFFI 0.28 → 0.30
- **Breaking**: Attribute syntax changed (`#[uniffi::export]` instead of `#[uniffi(...)]`)
- **Breaking**: Error handling syntax changed
- **Migration**: Update all annotations, regenerate bindings

#### Rust 1.75 → 1.80
- **Change**: WASM target updates
- **Change**: Improved error messages
- **Impact**: None for this template

#### Android NDK r23 → r25
- **Change**: Deprecated support for API < 21
- **Change**: Updated linker behavior
- **Impact**: Update minimum API level to 21

### Testing Compatibility

To verify compatibility with your versions:

```bash
# Check versions
rustc --version
cargo --version
xcodebuild -version
echo $ANDROID_NDK_ROOT

# Run compatibility test
./scripts/build-all.sh && ./scripts/test-all.sh
```

### Updating Dependencies

**Safe Update Process:**

1. **Update one component at a time**
   ```bash
   cargo update --package uniffi
   ./scripts/build-all.sh
   ./scripts/test-all.sh
   ```

2. **Test on all platforms**
   - Build succeeds on all targets
   - All tests pass
   - Example apps still work

3. **Document breaking changes**
   - Update this compatibility matrix
   - Note migration steps in CHANGELOG.md

### Getting Help with Compatibility

- **Rust/Cargo**: Check [Rust release notes](https://github.com/rust-lang/rust/releases)
- **UniFFI**: See [UniFFI changelog](https://github.com/mozilla/uniffi-rs/blob/main/CHANGELOG.md)
- **Android NDK**: Review [NDK release notes](https://developer.android.com/ndk/downloads/revision_history)
- **Xcode**: Check [Xcode release notes](https://developer.apple.com/documentation/xcode-release-notes)

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
