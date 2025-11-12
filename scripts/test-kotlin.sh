#!/bin/bash
set -e

echo "[TEST] Testing Kotlin Platforms..."
echo ""

# Navigate to project root
cd "$(dirname "$0")/.."

# Check if bindings are generated
if [ ! -d "platforms/kotlin/src/commonMain/kotlin/uniffi" ]; then
    echo "[WARNING]  Kotlin bindings not found. Building first..."
    ./build-kotlin.sh
    echo ""
fi

# Run Kotlin tests
echo "════════════════════════════════════════════════════════════"
echo "Running Kotlin Multiplatform Tests"
echo "════════════════════════════════════════════════════════════"
echo ""

cd platforms/kotlin

# Check if Gradle wrapper exists, if not use system gradle
if [ -f "./gradlew" ]; then
    GRADLE_CMD="./gradlew"
elif command -v gradle &> /dev/null; then
    GRADLE_CMD="gradle"
else
    echo "[WARNING]  Gradle not found. Skipping Kotlin tests."
    echo ""
    echo "To run Kotlin tests, either:"
    echo "  1. Install Gradle: https://gradle.org/install/"
    echo "  2. Or run './gradlew wrapper' in platforms/kotlin/ to create a wrapper"
    echo ""
    TEST_RESULT=0
    cd ../..
    exit 0
fi

# Run JVM tests (works with native library loading)
echo " Running JVM tests..."
if $GRADLE_CMD jvmTest --console=plain; then
    echo ""
    echo "[SUCCESS] Kotlin JVM tests passed!"
    TEST_RESULT=0
else
    echo ""
    echo "[FAILED] Kotlin JVM tests failed!"
    TEST_RESULT=1
fi

# Note about Android unit tests
echo ""
echo "[INFO] Android unit tests are skipped (require emulator/device)."
echo "       JVM tests verify the Kotlin bindings work correctly."

cd ../..

echo ""
echo "════════════════════════════════════════════════════════════"
echo "Test Summary"
echo "════════════════════════════════════════════════════════════"
echo ""

if [ $TEST_RESULT -eq 0 ]; then
    echo "[SUCCESS] All Kotlin platform tests passed!"
    echo ""
    echo " Test Report:"
    echo "   JVM: platforms/kotlin/build/reports/tests/jvmTest/index.html"
    echo ""
    echo " Note: Android tests require running on an emulator/device."
    exit 0
else
    echo "[FAILED] Some tests failed. Check the output above."
    echo ""
    echo " Test Report:"
    echo "   Check platforms/kotlin/build/reports/tests/ for detailed reports"
    exit 1
fi
