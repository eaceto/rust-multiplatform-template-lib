# Testing Guide

This guide explains how to run tests for the Rust Multiplatform Template Library across all supported platforms.

## Quick Start

### Run All Tests

```bash
./scripts/test-all.sh
```

This runs tests for:
- ✅ Rust core library (unit + integration + doc tests)
- ✅ Apple platforms (iOS + macOS Swift tests)
- ✅ Kotlin platforms (JVM tests)

### Run Platform-Specific Tests

```bash
# Rust tests only
cargo test

# Apple platforms (iOS + macOS)
./scripts/test-apple.sh

# Kotlin platforms (JVM)
./scripts/test-kotlin.sh
```

---

## Rust Tests

### Running Tests

```bash
# All tests (unit + integration + doc)
cargo test

# Only unit tests
cargo test --lib

# Only integration tests
cargo test --test '*'

# Only doc tests
cargo test --doc

# Specific test
cargo test test_echo_with_value

# With output
cargo test -- --nocapture
```

### Test Coverage

**Unit Tests** (`tests/template_tests.rs`):
- `test_echo_with_value` - Basic echo functionality
- `test_echo_with_empty` - Empty string handling
- `test_echo_at_max_size` - Maximum size (1MB) handling
- `test_echo_just_under_max_size` - Just under max size
- `test_echo_input_too_large` - Error handling for oversized input
- `test_echo_with_unicode` - Unicode character support
- `test_echo_with_null_bytes` - Invalid character detection
- `test_random_in_range` - Random number generation
- `test_random_generates_different_values` - Randomness verification
- `test_cancellation_token` - Cancellation support
- `test_template_config` - Configuration objects
- `smoke_uniffi_api` - UniFFI integration

**Doc Tests** (inline in source code):
- `template::echo` - Documentation example
- `template::random` - Documentation example

---

## Swift/Apple Tests

### Running Tests

```bash
# All Apple platform tests
./scripts/test-apple.sh

# Or manually
cd platforms/apple
swift test
```

### Test Coverage

**Platform Tests** (`Tests/TemplateTests/TemplateTests.swift`):
- `testEchoWithValue` - Basic echo
- `testEchoWithEmpty` - Empty string
- `testEchoAtMaxSize` - Maximum size handling
- `testRandom` - Random number generation
- `testCancellation` - Async cancellation

**Extension Tests** (`Tests/TemplateTests/ExtensionsTests.swift`):
- `testTemplateEcho` - Extension wrapper
- `testTemplateRandom` - Extension wrapper
- `testEchoResultDescription` - Result formatting
- `testEchoResultTimestamp` - Timestamp parsing
- `testErrorMapping` - Error conversion
- `testSafeOperation` - Result type handling
- `testConfigBuilder` - Configuration DSL
- Plus 9 more extension tests

**Total:** 21 tests

---

## Kotlin Tests

### Overview

Kotlin tests run on the **JVM target** because:
- ✅ JVM can load native libraries properly
- ❌ Android unit tests require an emulator/device
- ✅ JVM tests verify all Kotlin bindings work correctly

### Running Tests

```bash
# Via script (recommended)
./scripts/test-kotlin.sh

# Or directly with Gradle
cd platforms/kotlin
./gradlew jvmTest

# View test report
open build/reports/tests/jvmTest/index.html
```

### Test Coverage

**JVM Tests** (`src/commonTest/kotlin/TemplateTest.kt`):
- `testEchoWithValue` - Basic echo functionality
- `testEchoWithEmpty` - Empty string handling
- `testEchoAtMaxSize` - Maximum size (1MB) handling
- `testEchoWithLargeInput` - Error handling for oversized input
- `testRandom` - Random number generation (100 iterations)

**Total:** 5 tests (all async/suspend)

### Android Testing

Android tests **cannot run** as standard unit tests because they require:
- Physical device or emulator
- Proper JNI library loading
- Android runtime environment

To test on Android:

1. **Using Android Studio:**
   ```bash
   # Build the library
   ./scripts/build-kotlin.sh

   # Open the demo app
   cd apps/android
   # Open in Android Studio, then run on device/emulator
   ```

2. **Using Demo App:**
   - The `apps/android` demo app serves as an integration test
   - Run it on a device/emulator to verify functionality

---

## Test Results

### Expected Output

When all tests pass, you should see:

```
════════════════════════════════════════════════════════════
 Test Summary
════════════════════════════════════════════════════════════

[SUCCESS] All tests passed!

Test Coverage:
   [SUCCESS] Rust core library (unit + integration + doc tests)
   [SUCCESS] Apple platforms (iOS + macOS Swift tests)
   [SUCCESS] Kotlin platforms (Android + JVM tests)
```

### Test Reports

After running tests, detailed HTML reports are available:

```
# Rust tests
target/doc/index.html

# Swift tests
.build/x86_64-apple-macosx/debug/*.xctest

# Kotlin JVM tests
platforms/kotlin/build/reports/tests/jvmTest/index.html
```

---

## Troubleshooting

### Rust Tests

**Problem:** Tests fail to compile
```
error[E0433]: failed to resolve: use of undeclared crate or module
```

**Solution:** Rebuild the library
```bash
cargo clean
cargo build
cargo test
```

---

### Swift Tests

**Problem:** Module not found
```
error: no such module 'Template'
```

**Solution:** Build first, then test
```bash
./scripts/build-apple.sh
./scripts/test-apple.sh
```

---

### Kotlin Tests

**Problem:** Native library not found (Android unit tests)
```
java.lang.UnsatisfiedLinkError: Native library not found
```

**Solution:** Use JVM tests instead
```bash
cd platforms/kotlin
./gradlew jvmTest  # Works with native libraries
```

**Problem:** Gradle wrapper not found
```
./gradlew: command not found
```

**Solution:** Gradle wrapper is now included
```bash
cd platforms/kotlin
chmod +x gradlew
./gradlew jvmTest
```

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Install Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable

    - name: Setup
      run: ./scripts/setup.sh

    - name: Build
      run: ./scripts/build-all.sh

    - name: Test
      run: ./scripts/test-all.sh
```

---

## Test Coverage Goals

Current coverage:
- ✅ **Rust:** 14 unit tests + 2 doc tests
- ✅ **Swift:** 21 tests (5 platform + 16 extension)
- ✅ **Kotlin:** 5 JVM tests

All critical paths are tested:
- ✅ Basic functionality (echo, random)
- ✅ Error handling (too large, invalid input)
- ✅ Edge cases (empty strings, max size, Unicode)
- ✅ Async/cancellation support
- ✅ Configuration and extension APIs

---

## Writing New Tests

### Rust

```rust
#[tokio::test]
async fn test_my_feature() {
    let result = echo("test".to_string(), None).await;
    assert!(result.is_ok());
}
```

### Swift

```swift
func testMyFeature() async throws {
    let result = try await echo(input: "test", token: nil)
    XCTAssertNotNil(result)
}
```

### Kotlin

```kotlin
@Test
fun testMyFeature() = runTest {
    val result = templateEcho("test", null)
    assertTrue(result != null)
}
```

---

## See Also

- [DEVELOPMENT.md](../DEVELOPMENT.md) - Development guide
- [README.md](../README.md) - Project overview
- [SWIFT_EXAMPLES.md](SWIFT_EXAMPLES.md) - Swift usage examples
- [KOTLIN_EXAMPLES.md](KOTLIN_EXAMPLES.md) - Kotlin usage examples
