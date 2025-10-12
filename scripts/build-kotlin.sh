#!/bin/bash
set -e

echo "🔨 Building Rust Multiplatform Template for Android and JVM..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Set NDK_HOME if not already set (try common locations)
if [ -z "$NDK_HOME" ]; then
    if [ -n "$ANDROID_NDK_HOME" ]; then
        export NDK_HOME="$ANDROID_NDK_HOME"
    elif [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME/ndk" ]; then
        # Find the latest NDK version
        NDK_VERSION=$(ls -1 "$ANDROID_HOME/ndk" | sort -V | tail -1)
        if [ -n "$NDK_VERSION" ]; then
            export NDK_HOME="$ANDROID_HOME/ndk/$NDK_VERSION"
        fi
    fi
fi

# Detect NDK host platform
if [ "$(uname)" == "Darwin" ]; then
    NDK_HOST="darwin-x86_64"
elif [ "$(uname)" == "Linux" ]; then
    NDK_HOST="linux-x86_64"
else
    NDK_HOST="unknown"
fi

# Build Android targets
echo ""
echo "📱 Building for Android..."
echo ""

if [ -z "$NDK_HOME" ]; then
    echo "⚠️  NDK_HOME not set - skipping Android build"
    echo ""
    echo "To build for Android, set NDK_HOME:"
    echo "  export NDK_HOME=\$ANDROID_HOME/ndk/<version>"
    echo "  or"
    echo "  export NDK_HOME=/path/to/android-ndk"
    echo ""
else
    echo "✅ NDK_HOME: $NDK_HOME"

    # Verify NDK toolchain exists
    TOOLCHAIN_DIR="$NDK_HOME/toolchains/llvm/prebuilt/$NDK_HOST"
    if [ ! -d "$TOOLCHAIN_DIR" ]; then
        echo "⚠️  NDK toolchain not found at: $TOOLCHAIN_DIR"
        echo "Skipping Android build"
    else
        echo "✅ NDK toolchain verified"

        # Add Rust Android targets if not already added
        echo "🔧 Adding Rust Android targets..."
        rustup target add aarch64-linux-android 2>/dev/null || true
        rustup target add armv7-linux-androideabi 2>/dev/null || true
        rustup target add i686-linux-android 2>/dev/null || true
        rustup target add x86_64-linux-android 2>/dev/null || true

        # Update cargo config with NDK paths
        echo "📝 Configuring cargo for Android NDK..."
        mkdir -p .cargo

        cat > .cargo/config.toml << EOF
[target.aarch64-linux-android]
ar = "$TOOLCHAIN_DIR/bin/llvm-ar"
linker = "$TOOLCHAIN_DIR/bin/aarch64-linux-android21-clang"

[target.armv7-linux-androideabi]
ar = "$TOOLCHAIN_DIR/bin/llvm-ar"
linker = "$TOOLCHAIN_DIR/bin/armv7a-linux-androideabi21-clang"

[target.i686-linux-android]
ar = "$TOOLCHAIN_DIR/bin/llvm-ar"
linker = "$TOOLCHAIN_DIR/bin/i686-linux-android21-clang"

[target.x86_64-linux-android]
ar = "$TOOLCHAIN_DIR/bin/llvm-ar"
linker = "$TOOLCHAIN_DIR/bin/x86_64-linux-android21-clang"
EOF

        # Build for all Android architectures
        echo ""
        echo "🏗️  Building native libraries for Android..."
        echo ""

        echo "📱 [1/4] Building for arm64-v8a (aarch64-linux-android)..."
        cargo build --release --target aarch64-linux-android

        echo "📱 [2/4] Building for armeabi-v7a (armv7-linux-androideabi)..."
        cargo build --release --target armv7-linux-androideabi

        echo "📱 [3/4] Building for x86 (i686-linux-android)..."
        cargo build --release --target i686-linux-android

        echo "📱 [4/4] Building for x86_64 (x86_64-linux-android)..."
        cargo build --release --target x86_64-linux-android

        # Copy to jniLibs
        echo ""
        echo "📦 Copying libraries to jniLibs directory..."
        mkdir -p platforms/kotlin/src/jniLibs/{arm64-v8a,armeabi-v7a,x86,x86_64}

        cp target/aarch64-linux-android/release/librust_multiplatform_template_lib.so \
           platforms/kotlin/src/jniLibs/arm64-v8a/

        cp target/armv7-linux-androideabi/release/librust_multiplatform_template_lib.so \
           platforms/kotlin/src/jniLibs/armeabi-v7a/

        cp target/i686-linux-android/release/librust_multiplatform_template_lib.so \
           platforms/kotlin/src/jniLibs/x86/

        cp target/x86_64-linux-android/release/librust_multiplatform_template_lib.so \
           platforms/kotlin/src/jniLibs/x86_64/

        echo "✅ Android build complete!"
    fi
fi

# Build JVM targets
echo ""
echo "💻 Building for JVM..."
echo ""

PLATFORM=$(uname -s)
ARCH=$(uname -m)

echo "📍 Detected platform: $PLATFORM $ARCH"

if [ "$PLATFORM" = "Darwin" ]; then
    echo "🍎 Building for macOS..."

    # Build for Apple Silicon (primary as requested)
    echo "🍎 Building for macOS Apple Silicon (aarch64)..."
    cargo build --release --target aarch64-apple-darwin

    # Copy to JVM resources
    echo "📦 Copying libraries to JVM resources..."
    mkdir -p platforms/kotlin/src/jvmMain/kotlin

    cp target/aarch64-apple-darwin/release/librust_multiplatform_template_lib.dylib \
       platforms/kotlin/src/jvmMain/kotlin/

    echo "✅ macOS library built and copied"

elif [ "$PLATFORM" = "Linux" ]; then
    echo "🐧 Building for Linux x86_64..."
    cargo build --release

    echo "📦 Copying libraries to JVM resources..."
    mkdir -p platforms/kotlin/src/jvmMain/kotlin

    cp target/release/librust_multiplatform_template_lib.so \
       platforms/kotlin/src/jvmMain/kotlin/

    echo "✅ Linux library built and copied"

else
    echo "⚠️  Unsupported platform for JVM: $PLATFORM"
fi

# Generate Kotlin bindings
echo ""
echo "🔧 Generating Kotlin bindings..."
mkdir -p platforms/kotlin/src/commonMain/kotlin

# Determine library extension based on platform
if [ "$PLATFORM" = "Darwin" ]; then
    LIB_EXT="dylib"
    LIB_PATH="target/aarch64-apple-darwin/release/librust_multiplatform_template_lib.dylib"
else
    LIB_EXT="so"
    LIB_PATH="target/release/librust_multiplatform_template_lib.so"
fi

cargo run --bin uniffi-bindgen -- \
    generate \
    --library "$LIB_PATH" \
    --language kotlin \
    --out-dir platforms/kotlin/src/commonMain/kotlin

echo ""
echo "✅ Kotlin build complete!"
echo ""
echo "📊 Build Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "platforms/kotlin/src/jniLibs" ]; then
    echo "📁 Android Native Libraries:"
    for arch in arm64-v8a armeabi-v7a x86 x86_64; do
        if [ -f "platforms/kotlin/src/jniLibs/$arch/librust_multiplatform_template_lib.so" ]; then
            size=$(ls -lh "platforms/kotlin/src/jniLibs/$arch/librust_multiplatform_template_lib.so" | awk '{print $5}')
            echo "   ✅ $arch: $size"
        fi
    done
fi

echo ""
echo "📁 JVM Native Libraries:"
if [ -d "platforms/kotlin/src/jvmMain/kotlin" ]; then
    ls -lh platforms/kotlin/src/jvmMain/kotlin/librust_multiplatform_template_lib.* 2>/dev/null || echo "   (none)"
fi

echo ""
echo "📦 Kotlin Bindings:"
if [ -f "platforms/kotlin/src/commonMain/kotlin/uniffi/template/template.kt" ]; then
    echo "   ✅ Generated at: platforms/kotlin/src/commonMain/kotlin/uniffi/template/template.kt"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 Next Steps:"
echo "   cd platforms/kotlin"
echo "   ./gradlew build                    # Build the Kotlin library"
echo "   ./gradlew publishToMavenLocal      # Publish to local Maven"
echo ""
