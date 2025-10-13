# Rust Multiplatform Template Library

A template project for creating Rust libraries that can be embedded in multiple platforms using UniFFI for automatic binding generation.

## Table of Contents

- [What is This?](#what-is-this)
- [Template Functions](#template-functions)
- [Quick Start](#quick-start)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
- [Demo Applications](#demo-applications)
  - [iOS/macOS App](#iosmacos-app)
  - [Android App](#android-app)
  - [Desktop CLI App](#desktop-cli-app)
- [Building](#building)
  - [Build All Platforms](#build-all-platforms)
  - [Build Specific Platforms](#build-specific-platforms)
- [Using the Generated Libraries](#using-the-generated-libraries)
  - [iOS/macOS (Swift)](#iosmacos-swift)
  - [Android (Kotlin/Java)](#android-kotlinjava)
  - [JVM Desktop (Kotlin/Java)](#jvm-desktop-kotlinjava)
- [Project Structure](#project-structure)
- [Testing](#testing)
  - [Test All Platforms](#test-all-platforms)
  - [Test Specific Platforms](#test-specific-platforms)
- [Documentation](#documentation)
  - [Generate Documentation for All Platforms](#generate-documentation-for-all-platforms)
  - [View Documentation Locally](#view-documentation-locally)
  - [Publishing Documentation](#publishing-documentation)
- [Development](#development)
- [Contributing](#contributing)
- [Contact](#contact)
- [License](#license)
- [Resources](#resources)

## What is This?

This template demonstrates how to write Rust code once and use it across:

- **iOS** (arm64 devices)
- **iOS Simulator** (arm64 M1+ and x86_64 Intel)
- **macOS** (arm64 Apple Silicon)
- **Android** (arm64-v8a, armeabi-v7a, x86, x86_64)
- **JVM** (Desktop applications in Java/Kotlin)

The template uses [UniFFI](https://mozilla.github.io/uniffi-rs/) to automatically generate Swift and Kotlin bindings from your Rust code.

## Template Functions

This template includes three simple example functions:

- **`helloWorld()`** → Returns `true` (demonstrates simple boolean return)
- **`echo(input: String)`** → Returns the input string, or `null`/`nil` if empty (demonstrates optional/nullable returns)
- **`random()`** → Returns a random number between 0.0 and 1.0 (demonstrates working with dependencies)

## Quick Start

### Prerequisites

- **Rust** - Install from [rustup.rs](https://rustup.rs/)
- **Xcode** (for iOS/macOS) - Required for Apple platforms
- **Android SDK & NDK** (for Android/JVM) - Required for Kotlin multiplatform builds
  - Set `ANDROID_HOME` environment variable, or
  - Create `platforms/kotlin/local.properties` with `sdk.dir` path
  - See [platforms/kotlin/README.md](platforms/kotlin/README.md) for setup details

### Setup

```bash
# Install required Rust targets
./scripts/setup.sh

# Build for all platforms
./scripts/build-all.sh
```

That's it! The library is now built for iOS, macOS, Android, and JVM.

## Demo Applications

This template includes three complete demo applications that show how to use the Rust library:

### iOS/macOS App

A SwiftUI app for iOS 14+ and macOS 11+ with interactive UI.

**Location:** `apps/apple/`

**Run:**
```bash
# 1. Build the library
./scripts/build-apple.sh

# 2. Open in Xcode
cd apps/apple
open TemplateDemo.xcodeproj

# 3. Select iPhone simulator or My Mac, then press Cmd+R
```

**Features:**
- Color-coded sections for each function
- Text input field for echo testing
- Real-time result display
- Error handling with alerts

### Android App

A Jetpack Compose app for Android 5.0+ (API 21+).

**Location:** `apps/android/`

**Run:**
```bash
# 1. Build the Kotlin library
./scripts/build-kotlin.sh

# 2. Build the AAR (Android Archive)
cd platforms/kotlin
./gradlew assembleRelease
cd ../..

# 3. Open in Android Studio
# File -> Open -> Select apps/android/

# 4. Run on emulator or device
```

**Features:**
- Material Design 3 with Jetpack Compose
- Color-coded cards for each function
- Interactive text input
- Modern Android UI patterns

### Desktop CLI App

A command-line JVM application that runs on macOS, Linux, and Windows.

**Location:** `apps/desktop/`

**Run:**
```bash
# 1. Build the Kotlin library and publish to Maven Local
cd platforms/kotlin
./gradlew publishToMavenLocal
cd ../..

# 2. Run the desktop app
cd apps/desktop
./gradlew run

# Or build a standalone JAR
./gradlew jar
java -jar build/libs/template-demo-desktop-1.0.0.jar
```

**Features:**
- Automated testing of all three functions
- Detailed output with statistics
- Portable JAR file
- No GUI dependencies

## Building

### Build All Platforms

```bash
./scripts/build-all.sh
```

This will build for all supported platforms (Apple, Android, JVM).

### Build Specific Platforms

**Apple platforms (iOS + macOS):**
```bash
./scripts/build-apple.sh
```

**Android + JVM:**
```bash
./scripts/build-kotlin.sh
```

## Using the Generated Libraries

### iOS/macOS (Swift)

1. In Xcode: **File → Add Package Dependencies**
2. Click **Add Local** and select the `platforms/apple` directory
3. Add the `Template` package to your target
4. Import and use in Swift:

```swift
import Template

let result = helloWorld()  // returns true
let text = echo(input: "Hello!")  // returns "Hello!"
let number = random()  // returns a random Double between 0.0 and 1.0
```

### Android (Kotlin/Java)

1. Build and publish to Maven Local:
   ```bash
   cd platforms/kotlin
   ./gradlew publishToMavenLocal
   ```

2. Add to your app's `build.gradle.kts`:
   ```kotlin
   dependencies {
       implementation("com.template:template:0.1.0")
   }
   ```

3. Use in Kotlin:
   ```kotlin
   import template.*

   val result = helloWorld()  // returns true
   val text = echo("Hello!")  // returns "Hello!"
   val number = random()  // returns a Double between 0.0 and 1.0
   ```

### JVM Desktop (Kotlin/Java)

Same as Android - the Kotlin Multiplatform setup supports both Android and JVM targets.

## Project Structure

```
rust-multiplatform-template-lib/
├── src/                          # Rust source code
│   ├── lib.rs                    # Library entry point
│   ├── template.rs               # Core Rust functions
│   ├── uniffi_wrapper.rs         # UniFFI bindings wrapper
│   ├── error.rs                  # Error types
│   └── bin/
│       └── uniffi-bindgen.rs     # UniFFI code generator
├── tests/                        # Rust integration tests
│   └── template_tests.rs         # Test suite
├── platforms/                    # Platform-specific bindings
│   ├── apple/                    # iOS/macOS Swift package
│   │   ├── Package.swift         # Swift Package Manager manifest
│   │   ├── Sources/Template/     # Generated Swift bindings
│   │   ├── Tests/                # Swift tests
│   │   └── xcframework/          # Built XCFramework
│   └── kotlin/                   # Android/JVM Kotlin package
│       ├── build.gradle.kts      # Gradle build configuration
│       ├── src/
│       │   ├── commonMain/kotlin/    # Generated Kotlin bindings
│       │   ├── commonTest/kotlin/    # Kotlin tests
│       │   ├── jniLibs/              # Android native libraries
│       │   └── jvmMain/kotlin/       # JVM native libraries
│       └── settings.gradle.kts
├── apps/                         # Demo applications
│   ├── apple/                    # iOS/macOS SwiftUI app
│   │   ├── TemplateDemo.xcodeproj/   # Xcode project
│   │   ├── TemplateDemo/             # Source files
│   │   └── README.md
│   ├── android/                  # Android Compose app
│   │   ├── app/                      # App module
│   │   │   ├── src/main/             # Source files
│   │   │   └── build.gradle.kts
│   │   ├── build.gradle.kts
│   │   └── settings.gradle.kts
│   └── desktop/                  # Desktop CLI JVM app
│       ├── src/main/kotlin/          # Kotlin source
│       ├── build.gradle.kts
│       └── settings.gradle.kts
├── scripts/                      # Build, test, and documentation scripts
│   ├── build-all.sh              # Build all platforms
│   ├── build-apple.sh            # Build script for iOS/macOS
│   ├── build-kotlin.sh           # Build script for Android/JVM
│   ├── test-all.sh               # Test all platforms
│   ├── test-apple.sh             # Test script for iOS/macOS
│   ├── test-kotlin.sh            # Test script for Android/JVM
│   ├── doc-all.sh                # Generate documentation
│   └── setup.sh                  # Install Rust targets
├── Cargo.toml                    # Rust package manifest
├── DEVELOPMENT.md                # Development guide
├── CONTRIBUTING.md               # Contributing guidelines
└── README.md                     # This file
```

## Testing

### Test All Platforms

```bash
./scripts/test-all.sh
```

This will run tests for:
- Rust core library (unit, integration, and doc tests)
- Apple platforms (iOS + macOS Swift tests)
- Kotlin platforms (Android + JVM tests)

### Test Specific Platforms

**Test Rust code:**
```bash
cargo test
```

**Test Apple platforms (iOS + macOS):**
```bash
./scripts/test-apple.sh
```

**Test Kotlin platforms (Android + JVM):**
```bash
./scripts/test-kotlin.sh
```

**Manual testing (if needed):**

For Swift:
```bash
cd platforms/apple
swift test
```

For Kotlin:
```bash
cd platforms/kotlin
./gradlew test
```

## Documentation

### Generate Documentation for All Platforms

```bash
./scripts/doc-all.sh
```

This will generate API documentation for:
- **Rust** → `docs/lib/index.html`

### View Documentation Locally

After running `./scripts/doc-all.sh`, open the generated HTML files in your browser:
```bash
open docs/lib/index.html
```

### Publishing Documentation

To publish to GitHub Pages:
```bash
git add docs/
git commit -m "Update documentation"
git push
```

Then enable GitHub Pages in your repository settings, pointing to the `docs/` folder.

## Development

For contributors and maintainers, see [DEVELOPMENT.md](DEVELOPMENT.md) for detailed instructions on:

- Setting up your development environment
- Building and testing
- Adding new features
- Customizing the template
- Troubleshooting common issues
- Contributing guidelines

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:

- Reporting bugs
- Suggesting enhancements
- Submitting pull requests
- Development workflow

## Contact

**Ezequiel (Kimi) Aceto**

- 📧 Email: [eaceto@pm.me](mailto:eaceto@pm.me)
- 🌐 Website: [eaceto.dev](https://eaceto.dev)
- 💼 LinkedIn: [linkedin.com/in/ezequielaceto](https://www.linkedin.com/in/ezequielaceto/)
- 🐙 GitHub: [@eaceto](https://github.com/eaceto)

For questions, issues, or discussions about this project:
- 🐛 [Report issues](https://github.com/eaceto/rust-multiplatform-template-lib/issues)
- 💬 [Start a discussion](https://github.com/eaceto/rust-multiplatform-template-lib/discussions)

## License

MIT License - see [LICENSE](LICENSE) for details.

Copyright (c) 2025 Ezequiel (Kimi) Aceto

## Resources

- [UniFFI Documentation](https://mozilla.github.io/uniffi-rs/)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform.html)
