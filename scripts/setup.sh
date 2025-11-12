#!/usr/bin/env bash
set -euo pipefail

echo "==> Setup checks for rust-multiplatform-template-lib"

command -v rustup >/dev/null 2>&1 || { echo "ERROR: rustup not found in PATH"; exit 1; }
command -v cargo >/dev/null 2>&1 || { echo "ERROR: cargo not found in PATH"; exit 1; }

echo "-> Ensuring required rust targets are installed"
RUST_TARGETS=(
  "aarch64-apple-darwin"
  "x86_64-apple-darwin"
  "aarch64-linux-android"
  "armv7-linux-androideabi"
  "x86_64-linux-android"
  "i686-linux-android"
)
for t in "${RUST_TARGETS[@]}"; do
  if ! rustup target list --installed | grep -q "^${t}$"; then
    echo "  Installing target: $t"
    rustup target add "$t" || true
  else
    echo "  Target already installed: $t"
  fi
done

echo "-> Checking Android NDK (if Android builds will be used)"
if [[ -z "${NDK_HOME:-}" ]]; then
  echo "  Warning: NDK_HOME is not set. Android builds may fail without it."
else
  if [[ ! -d "$NDK_HOME" ]]; then
    echo "ERROR: NDK_HOME is set but directory not found: $NDK_HOME"
    exit 1
  else
    echo "  Using NDK_HOME: $NDK_HOME"
  fi
fi

echo "-> Checking for uniffi-bindgen availability via cargo run --bin uniffi-bindgen"
if cargo run --bin uniffi-bindgen -- --version >/dev/null 2>&1; then
  echo "  uniffi-bindgen appears invokable via cargo run --bin uniffi-bindgen"
else
  echo "  Note: uniffi-bindgen not invokable via cargo run --bin uniffi-bindgen (this may be fine if you call it differently)."
fi

echo "-> Checking basic tools"
for cmd in git sed awk uname; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: required command not found: $cmd"; exit 1; }
done

echo "Setup checks complete."