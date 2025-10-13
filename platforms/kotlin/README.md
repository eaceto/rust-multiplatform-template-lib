# Kotlin Multiplatform Library

This directory contains the Kotlin Multiplatform wrapper for the Rust library, supporting both Android and JVM targets.

## Prerequisites

### For Full Build (Android + JVM):
- **Java 11+**
- **Android SDK** - Set `ANDROID_HOME` or create `local.properties`

### For JVM-Only:
- **Java 11+** only

## Setup Android SDK

If you have Android Studio installed, the SDK is typically at:
- **macOS/Linux**: `~/Library/Android/sdk` or `~/Android/Sdk`
- **Windows**: `%LOCALAPPDATA%\Android\Sdk`

### Option 1: Set Environment Variable

**macOS/Linux:**
```bash
export ANDROID_HOME=~/Library/Android/sdk
# Add to ~/.zshrc or ~/.bashrc to make permanent
```

**Windows:**
```batch
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
```

### Option 2: Create local.properties

Create `platforms/kotlin/local.properties`:

**macOS/Linux:**
```properties
sdk.dir=/Users/YOUR_USERNAME/Library/Android/sdk
```

**Windows:**
```properties
sdk.dir=C\:\\Users\\YOUR_USERNAME\\AppData\\Local\\Android\\Sdk
```

Replace `YOUR_USERNAME` with your actual username.

## Building

### Build All Targets (Android + JVM)

```bash
./gradlew build
```

### Build JVM Only

If you don't have Android SDK and only need JVM:

```bash
./gradlew jvmJar
```

### Publish to Maven Local

```bash
./gradlew publishToMavenLocal
```

This publishes to `~/.m2/repository/com/template/template/0.1.0/`

## Using the Library

### In Gradle Projects

Add to `build.gradle.kts`:

```kotlin
repositories {
    mavenLocal()  // or mavenCentral() if published
}

dependencies {
    implementation("com.template:template:0.1.0")
}
```

### In Maven Projects

Add to `pom.xml`:

```xml
<dependency>
    <groupId>com.template</groupId>
    <artifactId>template-jvm</artifactId>
    <version>0.1.0</version>
</dependency>
```

## Troubleshooting

### SDK Location Not Found

**Error:** `SDK location not found. Define a valid SDK location...`

**Solution:**
1. Install Android Studio and SDK
2. Set `ANDROID_HOME` environment variable
3. Or create `local.properties` file (see above)

### JNA Native Library Not Found

**Error:** `java.lang.UnsatisfiedLinkError`

**Solution:** Ensure the Rust library is built:
```bash
cd ../..
./scripts/build-kotlin.sh
```

### Build Fails After Rust Changes

1. Rebuild Rust: `../../scripts/build-kotlin.sh`
2. Clean: `./gradlew clean`
3. Rebuild: `./gradlew build`

## Project Structure

```
platforms/kotlin/
├── build.gradle.kts              # Build configuration
├── settings.gradle.kts           # Project settings
├── gradle.properties             # Gradle properties
├── local.properties              # SDK location (not in git)
├── src/
│   ├── commonMain/kotlin/        # Generated Kotlin bindings
│   ├── commonTest/kotlin/        # Kotlin tests
│   ├── jniLibs/                  # Android native libraries
│   │   ├── arm64-v8a/
│   │   ├── armeabi-v7a/
│   │   ├── x86/
│   │   └── x86_64/
│   └── jvmMain/kotlin/           # JVM native libraries
└── build/                        # Build outputs (generated)
    └── outputs/aar/              # Android Archive
```

## Learn More

- [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform.html)
- [Android Library Development](https://developer.android.com/studio/projects/android-library)
- [Maven Publishing](https://docs.gradle.org/current/userguide/publishing_maven.html)
