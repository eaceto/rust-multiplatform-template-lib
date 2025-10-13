#!/bin/bash
set -e

echo "[TEST] Running All Tests..."
echo ""

# Navigate to project root
cd "$(dirname "$0")/.."

# Track test failures
FAILED_TESTS=()

# Test 1: Rust Tests
echo "════════════════════════════════════════════════════════════"
echo "1️⃣  Testing Rust Core Library"
echo "════════════════════════════════════════════════════════════"
echo ""

if cargo test; then
    echo ""
    echo "[SUCCESS] Rust tests passed!"
else
    echo ""
    echo "[FAILED] Rust tests failed!"
    FAILED_TESTS+=("Rust")
fi

echo ""
echo ""

# Test 2: Apple Platforms
echo "════════════════════════════════════════════════════════════"
echo "2️⃣  Testing Apple Platforms (iOS, macOS)"
echo "════════════════════════════════════════════════════════════"
echo ""

if ./scripts/test-apple.sh; then
    echo ""
    echo "[SUCCESS] Apple platform tests passed!"
else
    echo ""
    echo "[FAILED] Apple platform tests failed!"
    FAILED_TESTS+=("Apple")
fi

echo ""
echo ""

# Test 3: Kotlin Platforms
echo "════════════════════════════════════════════════════════════"
echo "3️⃣  Testing Kotlin Platforms (Android, JVM)"
echo "════════════════════════════════════════════════════════════"
echo ""

if ./scripts/test-kotlin.sh; then
    echo ""
    echo "[SUCCESS] Kotlin platform tests passed!"
else
    echo ""
    echo "[FAILED] Kotlin platform tests failed!"
    FAILED_TESTS+=("Kotlin")
fi

echo ""
echo ""

# Summary
echo "════════════════════════════════════════════════════════════"
echo " Test Summary"
echo "════════════════════════════════════════════════════════════"
echo ""

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo "[SUCCESS] All tests passed!"
    echo ""
    echo "Test Coverage:"
    echo "   [SUCCESS] Rust core library (unit + integration + doc tests)"
    echo "   [SUCCESS] Apple platforms (iOS + macOS Swift tests)"
    echo "   [SUCCESS] Kotlin platforms (Android + JVM tests)"
    exit 0
else
    echo "[WARNING]  Some test suites failed:"
    for platform in "${FAILED_TESTS[@]}"; do
        echo "   [FAILED] $platform"
    done
    echo ""
    echo "Please check the error messages above for details."
    echo ""
    exit 1
fi
