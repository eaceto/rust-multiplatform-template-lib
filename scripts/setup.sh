#!/bin/bash

set -e

echo " Setting up - Installing required targets..."
echo ""

# Apple platforms
echo " Installing Apple platform targets..."
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
rustup target add x86_64-apple-ios
rustup target add aarch64-apple-darwin
rustup target add x86_64-apple-darwin

echo ""
echo " Installing Apple dependencies..."
gem install jazzy

# Android platforms
echo "Installing Android platform targets..."
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add i686-linux-android
rustup target add x86_64-linux-android

# Linux platforms
echo "Installing Linux platform targets..."
rustup target add x86_64-unknown-linux-gnu
rustup target add aarch64-unknown-linux-gnu

# -- Uncomment if needed --
# Windows platforms
# echo "Installing Windows platform targets..."
# rustup target add x86_64-pc-windows-gnu
# rustup target add x86_64-pc-windows-msvc

# WebAssembly
# echo "Installing WebAssembly target..."
# rustup target add wasm32-unknown-unknown

echo ""
echo "[SUCCESS] All targets installed successfully!"
echo ""
echo " Installed targets:"
rustup target list --installed | grep -E "(ios|darwin|android|linux|windows|wasm)"
echo ""
echo "[BUILD] You can now run ./build-all.sh to build for all platforms"
