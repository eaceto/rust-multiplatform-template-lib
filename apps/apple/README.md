# Template Demo App

A simple iOS/macOS SwiftUI application demonstrating the Rust Multiplatform Template Library.

## Features

This demo app showcases the async functions from the template library:

1. **Echo** - String input/output with metadata and cancellation support
2. **Random** - Random number generation using Rust's rand crate

## Quick Start

### Step 1: Build the Rust Library

Before opening the demo app, build the library:

```bash
cd ../..
./scripts/build-apple.sh
cd apps/apple
```

### Step 2: Open and Run

1. **Open the Xcode project:**
   ```bash
   open DemoApp.xcodeproj
   ```

2. **Select your target:**
   - Choose iPhone simulator or My Mac from the scheme selector
   - The Template library is already configured as a local package dependency

3. **Run the app** (⌘R)
