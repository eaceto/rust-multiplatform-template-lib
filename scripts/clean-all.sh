#!/bin/bash
set -e

echo "🧹 Cleaning all generated files and build artifacts..."
echo ""

# Navigate to project root
cd "$(dirname "$0")/.."

# Track what gets cleaned
CLEANED_ITEMS=()

# ============================
# Rust Build Artifacts
# ============================
echo "🦀 Cleaning Rust build artifacts..."
if [ -d "target" ]; then
    echo "   → Removing target/ directory"
    rm -rf target/
    CLEANED_ITEMS+=("Rust target/")
fi

if [ -f "Cargo.lock" ]; then
    echo "   → Removing Cargo.lock"
    rm -f Cargo.lock
    CLEANED_ITEMS+=("Cargo.lock")
fi

# ============================
# Apple Platform Artifacts
# ============================
echo ""
echo "🍎 Cleaning Apple platform artifacts..."

# Generated Swift bindings (auto-generated only, preserve manual files)
if [ -f "platforms/apple/Sources/Template/template.swift" ] || [ -f "platforms/apple/Sources/Template/Template.swift" ]; then
    echo "   → Removing auto-generated Swift bindings"
    rm -f platforms/apple/Sources/Template/template.swift
    rm -f platforms/apple/Sources/Template/Template.swift
    CLEANED_ITEMS+=("Apple: Swift bindings")
fi

if [ -f "platforms/apple/Sources/Template/templateFFI.h" ] || [ -f "platforms/apple/Sources/Template/TemplateFFI.h" ]; then
    echo "   → Removing auto-generated FFI header"
    rm -f platforms/apple/Sources/Template/templateFFI.h
    rm -f platforms/apple/Sources/Template/TemplateFFI.h
    CLEANED_ITEMS+=("Apple: FFI header")
fi

if [ -f "platforms/apple/Sources/Template/templateFFI.modulemap" ] || [ -f "platforms/apple/Sources/Template/TemplateFFI.modulemap" ]; then
    echo "   → Removing auto-generated FFI modulemap"
    rm -f platforms/apple/Sources/Template/templateFFI.modulemap
    rm -f platforms/apple/Sources/Template/TemplateFFI.modulemap
    CLEANED_ITEMS+=("Apple: FFI modulemap")
fi

if [ -f "platforms/apple/Sources/Template/module.modulemap" ]; then
    echo "   → Removing auto-generated module.modulemap"
    rm -f platforms/apple/Sources/Template/module.modulemap
    CLEANED_ITEMS+=("Apple: module.modulemap")
fi

# Keep TemplateExtensions.swift - it's manual!
if [ -f "platforms/apple/Sources/Template/TemplateExtensions.swift" ]; then
    echo "   ✓ Preserving manual TemplateExtensions.swift"
fi

# XCFramework
if [ -d "platforms/apple/xcframework" ]; then
    echo "   → Removing xcframework/"
    rm -rf platforms/apple/xcframework/
    CLEANED_ITEMS+=("Apple: xcframework/")
fi

# Swift Package Manager build
if [ -d "platforms/apple/.build" ]; then
    echo "   → Removing .build/"
    rm -rf platforms/apple/.build/
    CLEANED_ITEMS+=("Apple: .build/")
fi

if [ -d "platforms/apple/.swiftpm" ]; then
    echo "   → Removing .swiftpm/"
    rm -rf platforms/apple/.swiftpm/
    CLEANED_ITEMS+=("Apple: .swiftpm/")
fi

if [ -f "platforms/apple/Package.resolved" ]; then
    echo "   → Removing Package.resolved"
    rm -f platforms/apple/Package.resolved
    CLEANED_ITEMS+=("Apple: Package.resolved")
fi

# Xcode artifacts
if [ -d "platforms/apple/DerivedData" ]; then
    echo "   → Removing DerivedData/"
    rm -rf platforms/apple/DerivedData/
    CLEANED_ITEMS+=("Apple: DerivedData/")
fi

if [ -d "platforms/apple/build" ]; then
    echo "   → Removing build/"
    rm -rf platforms/apple/build/
    CLEANED_ITEMS+=("Apple: build/")
fi

# ============================
# Kotlin Platform Artifacts
# ============================
echo ""
echo "🤖 Cleaning Kotlin platform artifacts..."

# Generated Kotlin bindings
if [ -d "platforms/kotlin/src/commonMain/kotlin/uniffi" ]; then
    echo "   → Removing auto-generated uniffi bindings"
    rm -rf platforms/kotlin/src/commonMain/kotlin/uniffi/
    CLEANED_ITEMS+=("Kotlin: uniffi bindings")
fi

# JVM native libraries
if [ -d "platforms/kotlin/src/jvmMain" ]; then
    echo "   → Removing JVM native libraries"
    find platforms/kotlin/src/jvmMain -name "*.so" -delete 2>/dev/null || true
    find platforms/kotlin/src/jvmMain -name "*.dylib" -delete 2>/dev/null || true
    find platforms/kotlin/src/jvmMain -name "*.dll" -delete 2>/dev/null || true
    CLEANED_ITEMS+=("Kotlin: JVM native libs")
fi

# JNI libraries
if [ -d "platforms/kotlin/src/jniLibs" ]; then
    echo "   → Removing jniLibs/"
    rm -rf platforms/kotlin/src/jniLibs/
    CLEANED_ITEMS+=("Kotlin: jniLibs/")
fi

# Gradle build artifacts
if [ -d "platforms/kotlin/build" ]; then
    echo "   → Removing build/"
    rm -rf platforms/kotlin/build/
    CLEANED_ITEMS+=("Kotlin: build/")
fi

if [ -d "platforms/kotlin/.gradle" ]; then
    echo "   → Removing .gradle/"
    rm -rf platforms/kotlin/.gradle/
    CLEANED_ITEMS+=("Kotlin: .gradle/")
fi

if [ -d "platforms/kotlin/.kotlin" ]; then
    echo "   → Removing .kotlin/"
    rm -rf platforms/kotlin/.kotlin/
    CLEANED_ITEMS+=("Kotlin: .kotlin/")
fi

# KMM artifacts
if [ -d "platforms/kotlin/.konan" ]; then
    echo "   → Removing .konan/"
    rm -rf platforms/kotlin/.konan/
    CLEANED_ITEMS+=("Kotlin: .konan/")
fi

# Android artifacts
if [ -d "platforms/kotlin/.cxx" ]; then
    echo "   → Removing .cxx/"
    rm -rf platforms/kotlin/.cxx/
    CLEANED_ITEMS+=("Kotlin: .cxx/")
fi

# ============================
# Documentation Artifacts (Generated Rust Docs)
# ============================
echo ""
echo "📚 Cleaning generated documentation..."

# Only remove lib/ subdirectory (generated by cargo doc)
# Keep manually created docs like index.html, *.md
if [ -d "docs/lib" ]; then
    echo "   → Removing docs/lib/ (cargo doc output)"
    rm -rf docs/lib/
    CLEANED_ITEMS+=("Docs: lib/")
fi

echo "   ✓ Preserving manual documentation (index.html, *.md)"

# ============================
# App Build Artifacts
# ============================
echo ""
echo "📱 Cleaning app build artifacts..."

# Apple demo app
if [ -d "apps/apple/.build" ]; then
    echo "   → Removing apps/apple/.build/"
    rm -rf apps/apple/.build/
    CLEANED_ITEMS+=("Apps: Apple .build/")
fi

if [ -d "apps/apple/DerivedData" ]; then
    echo "   → Removing apps/apple/DerivedData/"
    rm -rf apps/apple/DerivedData/
    CLEANED_ITEMS+=("Apps: Apple DerivedData/")
fi

# Desktop app
if [ -d "apps/desktop/.gradle" ]; then
    echo "   → Removing apps/desktop/.gradle/"
    rm -rf apps/desktop/.gradle/
    CLEANED_ITEMS+=("Apps: Desktop .gradle/")
fi

if [ -d "apps/desktop/build" ]; then
    echo "   → Removing apps/desktop/build/"
    rm -rf apps/desktop/build/
    CLEANED_ITEMS+=("Apps: Desktop build/")
fi

# Android app
if [ -d "apps/android/.gradle" ]; then
    echo "   → Removing apps/android/.gradle/"
    rm -rf apps/android/.gradle/
    CLEANED_ITEMS+=("Apps: Android .gradle/")
fi

if [ -d "apps/android/build" ]; then
    echo "   → Removing apps/android/build/"
    rm -rf apps/android/build/
    CLEANED_ITEMS+=("Apps: Android build/")
fi

if [ -d "apps/android/app/build" ]; then
    echo "   → Removing apps/android/app/build/"
    rm -rf apps/android/app/build/
    CLEANED_ITEMS+=("Apps: Android app/build/")
fi

# ============================
# Temporary Files
# ============================
echo ""
echo "🗑️  Cleaning temporary files..."

# Find and remove common temp files
TEMP_COUNT=0
for pattern in "*.tmp" "*.bak" "*.orig" "*.log" "*.swp" "*.swo"; do
    while IFS= read -r file; do
        echo "   → Removing $file"
        rm -f "$file"
        ((TEMP_COUNT++))
    done < <(find . -name "$pattern" -type f 2>/dev/null || true)
done

if [ $TEMP_COUNT -gt 0 ]; then
    CLEANED_ITEMS+=("$TEMP_COUNT temporary files")
fi

# macOS metadata
DSSTORE_COUNT=$(find . -name ".DS_Store" -type f 2>/dev/null | wc -l | xargs)
if [ "$DSSTORE_COUNT" -gt 0 ]; then
    echo "   → Removing .DS_Store files ($DSSTORE_COUNT found)"
    find . -name ".DS_Store" -type f -delete 2>/dev/null || true
    CLEANED_ITEMS+=("$DSSTORE_COUNT .DS_Store files")
fi

# ============================
# Summary
# ============================
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✨ Cleanup Complete!"
echo "════════════════════════════════════════════════════════════"
echo ""

if [ ${#CLEANED_ITEMS[@]} -eq 0 ]; then
    echo "✓ No generated files found - workspace was already clean"
else
    echo "Cleaned ${#CLEANED_ITEMS[@]} categories:"
    for item in "${CLEANED_ITEMS[@]}"; do
        echo "  ✓ $item"
    done
fi

echo ""
echo "To rebuild everything, run:"
echo "  ./scripts/build-all.sh"
echo ""
