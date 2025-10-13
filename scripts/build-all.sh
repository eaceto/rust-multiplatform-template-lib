#!/bin/bash
set -e

echo "Building for all platforms..."
echo ""

# Navigate to project root
cd "$(dirname "$0")/.."

# Track build failures
FAILED_BUILDS=()

# Build Apple platforms (iOS, macOS)
echo "============================================================"
echo "Building Apple Platforms (iOS, macOS)"
echo "============================================================"
echo ""

if ./scripts/build-apple.sh; then
    echo ""
    echo "[SUCCESS] Apple platforms build successful"
else
    echo ""
    echo "[FAILED] Apple platforms build failed"
    FAILED_BUILDS+=("Apple")
fi

echo ""
echo ""

# Build Kotlin platforms (Android, JVM)
echo "============================================================"
echo "Building Kotlin Platforms (Android, JVM)"
echo "============================================================"
echo ""

if ./scripts/build-kotlin.sh; then
    echo ""
    echo "[SUCCESS] Kotlin platforms build successful"
else
    echo ""
    echo "[FAILED] Kotlin platforms build failed"
    FAILED_BUILDS+=("Kotlin")
fi

echo ""
echo ""

# Summary
echo "============================================================"
echo "Build Summary"
echo "============================================================"
echo ""

if [ ${#FAILED_BUILDS[@]} -eq 0 ]; then
    echo "[SUCCESS] All platform builds completed successfully!"
    echo ""
    echo "Build Artifacts:"
    echo ""
    echo "Apple Platforms:"
    echo "   - XCFramework: platforms/apple/xcframework/librust_multiplatform_template_lib.xcframework"
    echo "   - Swift bindings: platforms/apple/Sources/Template/"
    echo "   - Package: platforms/apple/Package.swift"
    echo ""
    echo "Kotlin Platforms:"
    echo "   - Android JNI libs: platforms/kotlin/src/jniLibs/"
    echo "   - JVM libs: platforms/kotlin/src/jvmMain/kotlin/"
    echo "   - Kotlin bindings: platforms/kotlin/src/commonMain/kotlin/"
    echo "   - Gradle project: platforms/kotlin/build.gradle.kts"
    echo ""
    exit 0
else
    echo "[WARNING] Some builds failed:"
    for platform in "${FAILED_BUILDS[@]}"; do
        echo "   [FAILED] $platform"
    done
    echo ""
    echo "Please check the error messages above and ensure:"
    echo "   - For Apple: Xcode and Rust targets are installed"
    echo "   - For Kotlin: Android NDK is configured (NDK_HOME)"
    echo ""
    exit 1
fi
