#!/bin/bash
set -e

echo "🧪 Running All Tests..."
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
    echo "✅ Rust tests passed!"
else
    echo ""
    echo "❌ Rust tests failed!"
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
    echo "✅ Apple platform tests passed!"
else
    echo ""
    echo "❌ Apple platform tests failed!"
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
    echo "✅ Kotlin platform tests passed!"
else
    echo ""
    echo "❌ Kotlin platform tests failed!"
    FAILED_TESTS+=("Kotlin")
fi

echo ""
echo ""

# Summary
echo "════════════════════════════════════════════════════════════"
echo "📊 Test Summary"
echo "════════════════════════════════════════════════════════════"
echo ""

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo "✅ All tests passed!"
    echo ""
    echo "Test Coverage:"
    echo "   ✅ Rust core library (unit + integration + doc tests)"
    echo "   ✅ Apple platforms (iOS + macOS Swift tests)"
    echo "   ✅ Kotlin platforms (Android + JVM tests)"
    exit 0
else
    echo "⚠️  Some test suites failed:"
    for platform in "${FAILED_TESTS[@]}"; do
        echo "   ❌ $platform"
    done
    echo ""
    echo "Please check the error messages above for details."
    echo ""
    exit 1
fi
