# Swift Usage Examples

This document shows how to use the Rust template library in Swift/iOS applications with all the new improvements.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Error Handling](#error-handling)
- [Async Operations](#async-operations)
- [Cancellation](#cancellation)
- [Configuration Objects](#configuration-objects)
- [Complete Example App](#complete-example-app)

---

## Basic Usage

### Echo with Rich Return Type

```swift
import Template

func basicExample() async {
    do {
        if let echoResult = try await echo(input: "Hello, Swift!", token: nil) {
            print("Text: \(echoResult.text)")
            print("Length: \(echoResult.length)")
            print("Timestamp: \(echoResult.timestamp)")

            if let hash = echoResult.hash {
                print("Hash: \(hash)")
            }
        } else {
            print("Empty input returned nil")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### Random Number Generation

```swift
func randomExample() async {
    let randomValue = await random()
    print("Random: \(randomValue)")  // 0.0 to 1.0
}
```

---

## Error Handling

### Structured Error Handling

The new error system provides structured error information instead of just strings:

```swift
import Template

func processInput(_ input: String) {
    do {
        let result = try echo(input: input)
        print("Success: \(result?.text ?? "nil")")
    } catch let error as TemplateError {
        switch error {
        case .InputTooLarge(let size, let max, let hash):
            print("Input too large!")
            print("  Size: \(size) bytes")
            print("  Maximum allowed: \(max) bytes")
            print("  Hash (for debugging): \(hash)")

            // Show user-friendly message
            let formatter = ByteCountFormatter()
            let sizeStr = formatter.string(fromByteCount: Int64(size))
            let maxStr = formatter.string(fromByteCount: Int64(max))
            showAlert(title: "Input Too Large",
                     message: "Your input (\(sizeStr)) exceeds the maximum size of \(maxStr)")

        case .InvalidInput(let message, let preview):
            print("Invalid input: \(message)")
            if let preview = preview {
                print("  Preview: \(preview)")
            }
            showAlert(title: "Invalid Input", message: message)

        case .OperationCancelled(let operation):
            print("Operation cancelled: \(operation)")
            showAlert(title: "Cancelled", message: "The operation was cancelled")
        }
    } catch {
        print("Unexpected error: \(error)")
    }
}

func showAlert(title: String, message: String) {
    // Your alert implementation
}
```

### Practical Error Handling Example

```swift
import UIKit
import Template

class InputViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!

    @IBAction func processButtonTapped(_ sender: UIButton) {
        guard let input = textField.text, !input.isEmpty else {
            resultLabel.text = "Please enter some text"
            return
        }

        do {
            if let result = try echo(input: input) {
                resultLabel.text = """
                Result: \(result.text)
                Length: \(result.length) characters
                Time: \(Date(timeIntervalSince1970: TimeInterval(result.timestamp)))
                """
            }
        } catch let error as TemplateError {
            handleTemplateError(error)
        } catch {
            resultLabel.text = "Unexpected error: \(error.localizedDescription)"
        }
    }

    func handleTemplateError(_ error: TemplateError) {
        switch error {
        case .InputTooLarge(let size, let max, _):
            let formatter = ByteCountFormatter()
            resultLabel.text = """
            ❌ Input too large
            Your input: \(formatter.string(fromByteCount: Int64(size)))
            Maximum: \(formatter.string(fromByteCount: Int64(max)))
            """

        case .InvalidInput(let message, let preview):
            var text = "❌ Invalid input: \(message)"
            if let preview = preview {
                text += "\nPreview: \(preview)"
            }
            resultLabel.text = text

        case .OperationCancelled(let operation):
            resultLabel.text = "⚠️ \(operation) was cancelled"
        }
    }
}
```

---

## Async Operations

### Basic Async Echo

```swift
import Template

func asyncExample() async {
    do {
        let result = try await echoAsync(input: "Async hello!", token: nil)
        if let result = result {
            print("Async result: \(result.text)")
            print("Completed at: \(result.timestamp)")
        }
    } catch let error as TemplateError {
        switch error {
        case .OperationCancelled(let operation):
            print("Cancelled: \(operation)")
        case .InputTooLarge(let size, let max, _):
            print("Too large: \(size) > \(max)")
        case .InvalidInput(let message, _):
            print("Invalid: \(message)")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### Using with SwiftUI

```swift
import SwiftUI
import Template

struct AsyncEchoView: View {
    @State private var input = ""
    @State private var result: EchoResult?
    @State private var isLoading = false
    @State private var error: TemplateError?

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter text", text: $input)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Process Async") {
                Task {
                    await processAsync()
                }
            }
            .disabled(isLoading)

            if isLoading {
                ProgressView()
            }

            if let result = result {
                VStack(alignment: .leading) {
                    Text("Result: \(result.text)")
                    Text("Length: \(result.length)")
                    Text("Time: \(Date(timeIntervalSince1970: TimeInterval(result.timestamp)))")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }

            if let error = error {
                ErrorView(error: error)
            }
        }
        .padding()
    }

    func processAsync() async {
        isLoading = true
        error = nil
        result = nil

        do {
            result = try await echoAsync(input: input, token: nil)
        } catch let templateError as TemplateError {
            error = templateError
        } catch {
            print("Unexpected error: \(error)")
        }

        isLoading = false
    }
}

struct ErrorView: View {
    let error: TemplateError

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch error {
            case .InputTooLarge(let size, let max, _):
                Text("❌ Input Too Large")
                    .font(.headline)
                Text("Size: \(ByteCountFormatter().string(fromByteCount: Int64(size)))")
                Text("Max: \(ByteCountFormatter().string(fromByteCount: Int64(max)))")

            case .InvalidInput(let message, let preview):
                Text("❌ Invalid Input")
                    .font(.headline)
                Text(message)
                if let preview = preview {
                    Text("Preview: \(preview)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

            case .OperationCancelled(let operation):
                Text("⚠️ Cancelled")
                    .font(.headline)
                Text("Operation: \(operation)")
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}
```

---

## Cancellation

### Basic Cancellation

```swift
import Template

func cancellableOperation() async {
    let cancellationToken = CancellationToken()

    // Start async operation
    Task {
        do {
            let result = try await echoAsync(
                input: "Long running operation",
                token: cancellationToken
            )
            print("Completed: \(result?.text ?? "nil")")
        } catch let error as TemplateError {
            if case .OperationCancelled(let operation) = error {
                print("Successfully cancelled: \(operation)")
            }
        }
    }

    // Cancel after 1 second
    Task {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        cancellationToken.cancel()
    }
}
```

### Cancellation with SwiftUI

```swift
import SwiftUI
import Template

struct CancellableView: View {
    @State private var input = ""
    @State private var result: EchoResult?
    @State private var isProcessing = false
    @State private var cancellationToken: CancellationToken?
    @State private var error: String?

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter text", text: $input)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Start") {
                    Task {
                        await startProcessing()
                    }
                }
                .disabled(isProcessing)

                Button("Cancel") {
                    cancelProcessing()
                }
                .disabled(!isProcessing)
                .foregroundColor(.red)
            }

            if isProcessing {
                ProgressView("Processing...")
            }

            if let result = result {
                Text("Result: \(result.text)")
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }

            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }

    func startProcessing() async {
        isProcessing = true
        error = nil
        result = nil

        // Create new cancellation token
        cancellationToken = CancellationToken()

        do {
            let processResult = try await echoAsync(
                input: input,
                token: cancellationToken
            )
            result = processResult
        } catch let templateError as TemplateError {
            if case .OperationCancelled = templateError {
                error = "Operation was cancelled"
            } else {
                error = "Error: \(templateError)"
            }
        } catch {
            error = "Unexpected error: \(error.localizedDescription)"
        }

        isProcessing = false
        cancellationToken = nil
    }

    func cancelProcessing() {
        cancellationToken?.cancel()
    }
}
```

---

## Configuration Objects

### Using TemplateConfig

```swift
import Template

// Create configuration with custom settings
let config = TemplateConfig(
    maxInputSize: 1000,  // 1KB limit
    enableValidation: true
)

print("Max size: \(config.maxInputSize())")
print("Validation: \(config.enableValidation())")

// Use the config
do {
    let result = try config.validateAndEcho(input: "test")
    if let result = result {
        print("Validated: \(result.text)")
    }
} catch let error as TemplateError {
    print("Validation failed: \(error)")
}
```

### Configuration Manager Pattern

```swift
import Template

class TemplateManager {
    private let standardConfig: TemplateConfig
    private let strictConfig: TemplateConfig

    init() {
        // Standard configuration: 1MB, validation enabled
        standardConfig = TemplateConfig(
            maxInputSize: 1_000_000,
            enableValidation: true
        )

        // Strict configuration: 10KB, validation enabled
        strictConfig = TemplateConfig(
            maxInputSize: 10_000,
            enableValidation: true
        )
    }

    func processWithStandardConfig(_ input: String) throws -> EchoResult? {
        try standardConfig.validateAndEcho(input: input)
    }

    func processWithStrictConfig(_ input: String) throws -> EchoResult? {
        try strictConfig.validateAndEcho(input: input)
    }

    func validateInput(_ input: String, strict: Bool = false) -> Bool {
        do {
            let config = strict ? strictConfig : standardConfig
            _ = try config.validateAndEcho(input: input)
            return true
        } catch {
            return false
        }
    }
}

// Usage
let manager = TemplateManager()

do {
    let result = try manager.processWithStandardConfig("Hello")
    print("Processed: \(result?.text ?? "nil")")
} catch let error as TemplateError {
    switch error {
    case .InputTooLarge(let size, let max, _):
        print("Input \(size) exceeds limit \(max)")
    case .InvalidInput(let message, _):
        print("Invalid: \(message)")
    case .OperationCancelled:
        print("Cancelled")
    }
}
```

---

## Complete Example App

Here's a complete SwiftUI app showcasing all features:

```swift
import SwiftUI
import Template

@main
struct TemplateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TemplateViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section("Basic Operations") {
                    Button("Test Random") {
                        Task {
                            await viewModel.testRandom()
                        }
                    }
                }

                Section("Echo") {
                    TextField("Input", text: $viewModel.input)

                    Button("Echo") {
                        Task {
                            await viewModel.echoAsync()
                        }
                    }
                }

                Section("Async with Cancellation") {
                    Button("Start Long Operation") {
                        Task {
                            await viewModel.startLongOperation()
                        }
                    }
                    .disabled(viewModel.isProcessing)

                    Button("Cancel") {
                        viewModel.cancelOperation()
                    }
                    .disabled(!viewModel.isProcessing)
                    .foregroundColor(.red)

                    if viewModel.isProcessing {
                        ProgressView()
                    }
                }

                Section("Result") {
                    if let result = viewModel.lastResult {
                        Text(result)
                            .foregroundColor(.green)
                    }

                    if let error = viewModel.lastError {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Template Library")
        }
    }
}

class TemplateViewModel: ObservableObject {
    @Published var input = ""
    @Published var lastResult: String?
    @Published var lastError: String?
    @Published var isProcessing = false

    private var cancellationToken: CancellationToken?
    private let config = TemplateConfig(maxInputSize: 1_000_000, enableValidation: true)

    func testRandom() async {
        let value = await random()
        await MainActor.run {
            lastResult = "Random: \(String(format: "%.6f", value))"
            lastError = nil
        }
    }

    func echoAsync() async {
        do {
            if let result = try await echo(input: input, token: nil) {
                await MainActor.run {
                    lastResult = """
                    Text: \(result.text)
                    Length: \(result.length)
                    Timestamp: \(result.timestamp)
                    """
                    lastError = nil
                }
            } else {
                await MainActor.run {
                    lastResult = "Empty input"
                    lastError = nil
                }
            }
        } catch let error as TemplateError {
            await MainActor.run {
                lastError = formatError(error)
                lastResult = nil
            }
        } catch {
            await MainActor.run {
                lastError = "Unexpected error: \(error.localizedDescription)"
                lastResult = nil
            }
        }
    }

    func startLongOperation() async {
        await MainActor.run {
            isProcessing = true
            lastError = nil
            lastResult = nil
            cancellationToken = CancellationToken()
        }

        do {
            let result = try await echo(
                input: "Long operation: \(input)",
                token: cancellationToken
            )

            await MainActor.run {
                if let result = result {
                    lastResult = "Completed: \(result.text)"
                }
                isProcessing = false
                cancellationToken = nil
            }
        } catch let error as TemplateError {
            await MainActor.run {
                lastError = formatError(error)
                isProcessing = false
                cancellationToken = nil
            }
        }
    }

    func cancelOperation() {
        cancellationToken?.cancel()
    }

    private func formatError(_ error: TemplateError) -> String {
        switch error {
        case .InputTooLarge(let size, let max, let hash):
            let formatter = ByteCountFormatter()
            return """
            Input too large:
            Size: \(formatter.string(fromByteCount: Int64(size)))
            Max: \(formatter.string(fromByteCount: Int64(max)))
            Hash: \(hash)
            """

        case .InvalidInput(let message, let preview):
            var text = "Invalid input: \(message)"
            if let preview = preview {
                text += "\nPreview: \(preview)"
            }
            return text

        case .OperationCancelled(let operation):
            return "Cancelled: \(operation)"
        }
    }
}
```

---

## Best Practices

1. **Always handle errors explicitly** - Don't just catch and ignore
2. **Use structured error matching** - Pattern match on error variants for better UX
3. **Cancel long operations** - Implement cancellation for better user experience
4. **Use configuration objects** - For reusable validation settings
5. **Update UI on main thread** - When using async operations in SwiftUI

---

*Last updated: 2025-01-11*
