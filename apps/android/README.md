# Template Demo - Android App

A Material Design 3 Android app built with Jetpack Compose that demonstrates the Rust Multiplatform Template Library.

## Features

This demo app showcases all three functions from the template library:

1. **Hello World** - Simple boolean return value
2. **Echo** - String input/output with optional handling
3. **Random** - Random number generation using Rust's rand crate

## Screenshots

The app provides an interactive UI with:
- **Material Design 3** color scheme
- **Color-coded cards** for each function (blue, green, orange)
- **Interactive text input** field for echo testing
- **Real-time result display** boxes
- **Error handling** with Material dialogs
- **Modern Compose UI** patterns

## Prerequisites

- **Android Studio** - Hedgehog (2023.1.1) or later
- **Android SDK** - API 21+ (Android 5.0+)
- **Rust library** - Built for Android

## Quick Start

### Step 1: Build the Rust Library

```bash
# From the project root
./scripts/build-kotlin.sh
```

This generates the native libraries for all Android architectures.

### Step 2: Build the AAR

The Android app depends on the Kotlin wrapper as an AAR file:

```bash
cd platforms/kotlin
./gradlew assembleRelease
cd ../..
```

This creates: `platforms/kotlin/build/outputs/aar/template-release.aar`

**Alternative:** Publish to Maven Local:

```bash
cd platforms/kotlin
./gradlew publishToMavenLocal
cd ../..
```

Then update `apps/android/app/build.gradle.kts` to use:
```kotlin
implementation("com.template:template:0.1.0")
```

### Step 3: Open in Android Studio

1. Open Android Studio
2. **File → Open**
3. Navigate to `apps/android/`
4. Select the directory and click **OK**

### Step 4: Run the App

1. Select a device or emulator (API 21+)
2. Click **Run** (or press Shift+F10)

## Project Structure

```
apps/android/
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   └── java/dev/eaceto/templatedemo/
│   │       └── MainActivity.kt          # Main Compose UI
│   ├── build.gradle.kts                 # App module config
│   └── proguard-rules.pro               # ProGuard rules for release
├── build.gradle.kts                     # Project-level config
├── settings.gradle.kts                  # Project settings
└── README.md                            # This file
```

## Building for Release

### Generate Signed APK

1. In Android Studio: **Build → Generate Signed Bundle / APK**
2. Select **APK**
3. Create or select a keystore
4. Choose **release** build type
5. Click **Finish**

### Command Line

```bash
cd apps/android
./gradlew assembleRelease
```

APK location: `app/build/outputs/apk/release/app-release-unsigned.apk`

## Customization

### Change App Name

Edit `app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Your App Name"
    ...>
```

### Change Colors

The app uses Material Design 3 theming. Color-coded sections are defined in `MainActivity.kt`:
- Blue: `Color(0xFFE3F2FD)` / `Color(0xFF2196F3)`
- Green: `Color(0xFFE8F5E9)` / `Color(0xFF4CAF50)`
- Orange: `Color(0xFFFFF3E0)` / `Color(0xFFFF9800)`

### Minimum SDK

Current minimum: API 21 (Android 5.0)

To change, edit `app/build.gradle.kts`:
```kotlin
defaultConfig {
    minSdk = 23  // Change to your target
    ...
}
```

## Troubleshooting

### Library Not Found

**Error**: `java.lang.UnsatisfiedLinkError` or `Could not find template.aar`

**Solution**: Build the Kotlin library and AAR:
```bash
cd ../../
./scripts/build-kotlin.sh
cd platforms/kotlin
./gradlew assembleRelease
```

### NDK Not Found

**Error**: `NDK not found`

**Solution**: Install NDK in Android Studio:
- **Tools → SDK Manager → SDK Tools**
- Check **NDK (Side by side)**
- Click **Apply**

### Build Errors After Rust Changes

If you modified the Rust code:

1. Rebuild the Rust library:
   ```bash
   cd ../../
   ./scripts/build-kotlin.sh
   ```

2. Rebuild the AAR:
   ```bash
   cd platforms/kotlin
   ./gradlew assembleRelease
   ```

3. Clean and rebuild the Android app:
   - In Android Studio: **Build → Clean Project**
   - Then: **Build → Rebuild Project**

## Code Examples

### Calling Hello World

```kotlin
import template.*

val result = helloWorld()
println(result)  // true
```

### Calling Echo

```kotlin
import template.*

val result = echo("Hello from Android!")
if (result != null) {
    println("Echo: $result")
} else {
    println("Empty input")
}
```

### Calling Random

```kotlin
import template.*

val number = random()
println("Random: %.6f".format(number))
```

## Learn More

- [Main README](../../README.md) - Project overview
- [Development Guide](../../DEVELOPMENT.md) - Building and customizing
- [Jetpack Compose](https://developer.android.com/jetpack/compose) - UI framework
- [Material Design 3](https://m3.material.io/) - Design system

## License

MIT License - Same as the parent project
