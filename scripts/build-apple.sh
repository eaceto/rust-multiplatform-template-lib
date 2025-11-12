#!/bin/bash
set -e

echo "Building for Apple platforms..."

# Set deployment targets
export IPHONEOS_DEPLOYMENT_TARGET=14.0
export MACOSX_DEPLOYMENT_TARGET=11.0

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf platforms/apple/xcframework/librust_multiplatform_template_lib.xcframework
rm -f platforms/apple/xcframework/librust_multiplatform_template_lib-sim.a
rm -f platforms/apple/xcframework/librust_multiplatform_template_lib-macos.a

# Build for all iOS targets
echo "Building for aarch64-apple-ios (device)..."
cargo build --release --target aarch64-apple-ios

echo "Building for aarch64-apple-ios-sim (M1+ simulator)..."
cargo build --release --target aarch64-apple-ios-sim

echo "Building for x86_64-apple-ios (Intel simulator)..."
cargo build --release --target x86_64-apple-ios

# Build for macOS (Apple Silicon only as specified)
echo "Building for aarch64-apple-darwin (Apple Silicon Mac)..."
cargo build --release --target aarch64-apple-darwin

# Create universal libraries
echo "Creating universal simulator library..."
mkdir -p platforms/apple/xcframework
lipo -create \
    target/aarch64-apple-ios-sim/release/librust_multiplatform_template_lib.a \
    target/x86_64-apple-ios/release/librust_multiplatform_template_lib.a \
    -output platforms/apple/xcframework/librust_multiplatform_template_lib-sim.a

# For macOS, we'll use only Apple Silicon (as requested)
echo "Copying macOS library (Apple Silicon only)..."
cp target/aarch64-apple-darwin/release/librust_multiplatform_template_lib.a \
    platforms/apple/xcframework/librust_multiplatform_template_lib-macos.a

# Generate Swift bindings
echo "Generating Swift bindings..."
# Clean old AUTO-GENERATED bindings first to avoid conflicts
# IMPORTANT: Only remove auto-generated files, preserve manual files like TemplateExtensions.swift
rm -f platforms/apple/Sources/Template/template.swift
rm -f platforms/apple/Sources/Template/Template.swift
rm -f platforms/apple/Sources/Template/templateFFI.h
rm -f platforms/apple/Sources/Template/TemplateFFI.h
rm -f platforms/apple/Sources/Template/templateFFI.modulemap
rm -f platforms/apple/Sources/Template/TemplateFFI.modulemap
rm -f platforms/apple/Sources/Template/module.modulemap
mkdir -p platforms/apple/Sources/Template

# Generate bindings from UDL file
cargo run --bin uniffi-bindgen -- \
    generate \
    src/template.udl \
    --language swift \
    --out-dir platforms/apple/Sources/Template

# Create module.modulemap for the C headers
echo "Creating module.modulemap..."
cat > platforms/apple/Sources/Template/module.modulemap << 'EOF'
module TemplateFFI {
    header "TemplateFFI.h"
    export *
}
EOF

# Create XCFramework with iOS and macOS
echo "Creating XCFramework..."
xcodebuild -create-xcframework \
    -library target/aarch64-apple-ios/release/librust_multiplatform_template_lib.a \
    -headers platforms/apple/Sources/Template \
    -library platforms/apple/xcframework/librust_multiplatform_template_lib-sim.a \
    -headers platforms/apple/Sources/Template \
    -library platforms/apple/xcframework/librust_multiplatform_template_lib-macos.a \
    -headers platforms/apple/Sources/Template \
    -output platforms/apple/xcframework/librust_multiplatform_template_lib.xcframework

echo "[SUCCESS] Build complete!"
echo ""
echo "Outputs:"
echo "   - XCFramework: platforms/apple/xcframework/librust_multiplatform_template_lib.xcframework"
echo "   - Swift bindings: platforms/apple/Sources/Template/Template.swift"
echo "   - Package manifest: platforms/apple/Package.swift"
echo ""
echo "Supported Platforms:"
echo "   - iOS (arm64 device)"
echo "   - iOS Simulator (arm64 + x86_64)"
echo "   - macOS (arm64 Apple Silicon)"
echo ""
echo "To use in Xcode:"
echo "   1. File -> Add Package Dependencies"
echo "   2. Select the platforms/apple directory"
echo "   3. Import Template in your Swift files"
