#!/bin/bash
set -e

echo "🖥️  Running Desktop App..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Check if desktop app directory exists
if [ ! -d "apps/desktop" ]; then
    echo "❌ [ERROR] Desktop app directory not found: apps/desktop"
    exit 1
fi

# Navigate to desktop app directory
cd apps/desktop

echo ""
echo "📦 Checking Kotlin library..."

# Check if library is published to Maven local
MAVEN_LOCAL=~/.m2/repository/com/template/template-jvm
if [ ! -d "$MAVEN_LOCAL" ]; then
    echo "⚠️  [WARNING] Kotlin library not found in Maven local repository"
    echo ""
    echo "Building and publishing Kotlin library first..."
    echo ""

    cd ../../platforms/kotlin

    # Check if native libraries exist
    if [ ! -d "src/jvmMain/kotlin" ] || [ -z "$(ls -A src/jvmMain/kotlin/*.dylib 2>/dev/null || ls -A src/jvmMain/kotlin/*.so 2>/dev/null)" ]; then
        echo "⚠️  [WARNING] Native libraries not found"
        echo ""
        echo "Building Kotlin library with native dependencies..."
        echo ""

        cd ../..
        ./scripts/build-kotlin.sh
        cd platforms/kotlin
    fi

    echo ""
    echo "📦 Publishing to Maven local..."
    ./gradlew publishToMavenLocal

    cd ../../apps/desktop
    echo ""
    echo "✅ [SUCCESS] Kotlin library published"
else
    echo "✅ [SUCCESS] Kotlin library found in Maven local"
fi

echo ""
echo "🚀 Running desktop app..."
echo ""

# Run the desktop app
./gradlew run

echo ""
echo "✅ [SUCCESS] Desktop app execution complete!"
echo ""
