#!/bin/bash
set -e

echo "[TEST] Testing Apple Platforms..."
echo ""

# Navigate to project root
cd "$(dirname "$0")/.."

# First, ensure the library is built
if [ ! -d "platforms/apple/xcframework/librust_multiplatform_template_lib.xcframework" ]; then
    echo "[WARNING]  XCFramework not found. Building first..."
    ./build-apple.sh
    echo ""
fi

# Run Swift tests
echo "════════════════════════════════════════════════════════════"
echo "Running Swift Package Tests"
echo "════════════════════════════════════════════════════════════"
echo ""

cd platforms/apple

# Run swift tests
if swift test; then
    echo ""
    echo "[SUCCESS] Swift tests passed!"
    TEST_RESULT=0
else
    echo ""
    echo "[FAILED] Swift tests failed!"
    TEST_RESULT=1
fi

cd ../..

echo ""
echo "════════════════════════════════════════════════════════════"
echo "Test Summary"
echo "════════════════════════════════════════════════════════════"
echo ""

if [ $TEST_RESULT -eq 0 ]; then
    echo "[SUCCESS] All Apple platform tests passed!"
    exit 0
else
    echo "[FAILED] Some tests failed. Check the output above."
    exit 1
fi
