# Template Demo - Desktop CLI App

A command-line JVM application that demonstrates the Rust Multiplatform Template Library. Runs on macOS, Linux, and Windows.

## Prerequisites

- **Java 11+** - JDK 11 or later
- **Android SDK** - Required to build the Kotlin multiplatform library
- **Rust library** - Must be built first
- **Gradle** - Included via wrapper (no separate installation needed)

## Quick Start

### Step 1: Setup Android SDK (If Not Already Installed)

The Kotlin multiplatform library requires Android SDK even for JVM builds.

**If you have Android Studio:**
Set the environment variable or create `platforms/kotlin/local.properties`:

```properties
sdk.dir=/Users/YOUR_USERNAME/Library/Android/sdk
```

**macOS/Linux typical locations:**
- `~/Library/Android/sdk`
- `~/Android/Sdk`

**Windows:**
- `C:\Users\YOUR_USERNAME\AppData\Local\Android\Sdk`

Or set environment variable:
```bash
export ANDROID_HOME=~/Library/Android/sdk
```

See [platforms/kotlin/README.md](../../platforms/kotlin/README.md) for detailed setup.

### Step 2: Build and Publish the Kotlin Library

```bash
# From the project root
cd platforms/kotlin
./gradlew publishToMavenLocal
cd ../..
```

This publishes the library to your local Maven repository (`~/.m2/repository/`).

### Step 3: Run the App

```bash
cd apps/desktop
./gradlew run
```

That's it! The app will automatically test all functions and display results.

## Building

### Run Directly

```bash
./gradlew run
```

### Build JAR

```bash
./gradlew jar
```

Output: `build/libs/template-demo-desktop-1.0.0.jar`

### Run JAR

```bash
java -jar build/libs/template-demo-desktop-1.0.0.jar
```

The JAR includes all dependencies (fat JAR), so it's fully portable.
