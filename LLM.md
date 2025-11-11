# LLM Integration Guide

This document explains how to use the LLM (Large Language Model) functionality in the Rust Multiplatform Template Library, powered by HuggingFace Candle.

## Overview

The library provides LLM capabilities through the Candle framework, with support for:
- **Model metadata loading** - Read model information without loading full weights
- **Backend detection** - Identify available compute backends (Metal, CPU, etc.)
- **GGUF format support** - Work with quantized models in GGUF format

## Quick Start

### 1. Backend Detection

First, check what compute backends are available on your platform:

**Rust:**
```rust
use rust_multiplatform_template_lib::get_backend_info;

let info = get_backend_info().unwrap();
println!("Backend: {}", info);
// Output: "Candle backend: Metal (Apple Silicon), CPU threads: 12, Platform: macos"
```

**Swift (iOS/macOS):**
```swift
import Template

let info = try getBackendInfo()
print("Backend: \(info)")
// Output: "Candle backend: Metal (iOS), CPU threads: 6, Platform: ios"
```

**Kotlin (Android/JVM):**
```kotlin
import uniffi.rust_multiplatform_template_lib.*

val info = getBackendInfo()
println("Backend: $info")
// Output: "Candle backend: CPU (Android ARM64), CPU threads: 8, Platform: android"
```

---

## Model Metadata Loading

### What is Model Metadata?

Model metadata loading reads information from a GGUF model file **without loading the full model into memory**. This is useful for:
- ✅ Validating model files before loading
- ✅ Displaying model information to users
- ✅ Checking compatibility
- ✅ Fast operation (< 1ms typically)

### Getting a Test Model

For testing, you can use any GGUF format model. Here are some small models suitable for mobile:

**Recommended Test Models:**
- **TinyLlama-1.1B-Chat-v1.0** (~600MB Q4_K_M quantized)
- **Phi-2** (~1.6GB Q4_K_M quantized)
- **Qwen2-0.5B** (~350MB Q4_K_M quantized)

Download from HuggingFace:
```bash
# Example: Download TinyLlama
wget https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
```

---

## Usage Examples

### Rust Example

```rust
use rust_multiplatform_template_lib::{load_model_metadata, ModelMetadata};

fn main() {
    let model_path = "models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf";

    match load_model_metadata(model_path.to_string()) {
        Ok(metadata) => {
            println!("Model Type: {}", metadata.model_type);
            println!("Vocab Size: {}", metadata.vocab_size);
            println!("Context Length: {}", metadata.context_length);
            println!("Embedding Dims: {}", metadata.embedding_dimensions);
            println!("Parameters: {}", metadata.parameter_count);
            println!("File Size: {} bytes", metadata.file_size_bytes);
        }
        Err(e) => eprintln!("Error: {}", e),
    }
}
```

Run the example:
```bash
cargo run --example model_metadata
```

---

### iOS/macOS Example

#### 1. Add Model File to Your App

**Option A: Bundle with App (Small models only)**
1. Drag `.gguf` file into Xcode project
2. Ensure "Target Membership" includes your app
3. Access via `Bundle.main.path(forResource:ofType:)`

**Option B: Download at Runtime (Recommended for larger models)**
1. Download to Documents directory
2. Use `FileManager` to get path

#### 2. Swift Code

```swift
import SwiftUI
import Template

struct ModelInfoView: View {
    @State private var modelInfo: String = "Not loaded"
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Model Metadata").font(.title)

            Button("Load Model Info") {
                loadModelMetadata()
            }

            Text(modelInfo)
                .padding()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    func loadModelMetadata() {
        // Option 1: Bundled file
        guard let modelPath = Bundle.main.path(
            forResource: "tinyllama-1.1b-chat-v1.0.Q4_K_M",
            ofType: "gguf"
        ) else {
            errorMessage = "Model file not found in bundle"
            showError = true
            return
        }

        // Option 2: Documents directory
        // let documentsPath = FileManager.default.urls(
        //     for: .documentDirectory, in: .userDomainMask
        // )[0].appendingPathComponent("model.gguf").path

        do {
            let metadata = try loadModelMetadata(modelPath: modelPath)

            modelInfo = """
            Model Type: \(metadata.modelType)
            Vocab Size: \(metadata.vocabSize)
            Context Length: \(metadata.contextLength)
            Embedding Dims: \(metadata.embeddingDimensions)
            Parameters: \(metadata.parameterCount)
            File Size: \(formatBytes(metadata.fileSizeBytes))
            """
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
```

---

### Android Example

#### 1. Add Model File to Your App

**Option A: Assets Folder (Small models < 100MB)**
1. Place `.gguf` file in `app/src/main/assets/models/`
2. Copy to cache at runtime:

```kotlin
private fun copyModelFromAssets(context: Context, assetPath: String): String {
    val fileName = assetPath.substringAfterLast("/")
    val outputFile = File(context.cacheDir, fileName)

    if (!outputFile.exists()) {
        context.assets.open(assetPath).use { input ->
            outputFile.outputStream().use { output ->
                input.copyTo(output)
            }
        }
    }

    return outputFile.absolutePath
}
```

**Option B: External Storage (Larger models)**
1. Download to `getExternalFilesDir()`
2. Request storage permissions if needed

#### 2. Kotlin Code (Jetpack Compose)

```kotlin
import androidx.compose.runtime.*
import androidx.compose.material3.*
import androidx.compose.foundation.layout.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import uniffi.rust_multiplatform_template_lib.*

@Composable
fun ModelInfoScreen() {
    var modelInfo by remember { mutableStateOf("Not loaded") }
    var showError by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Model Metadata", style = MaterialTheme.typography.headlineMedium)

        Button(onClick = {
            try {
                // Copy model from assets to cache
                val modelPath = copyModelFromAssets(
                    context,
                    "models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
                )

                // Load metadata
                val metadata = loadModelMetadata(modelPath)

                modelInfo = buildString {
                    appendLine("Model Type: ${metadata.modelType}")
                    appendLine("Vocab Size: ${metadata.vocabSize}")
                    appendLine("Context Length: ${metadata.contextLength}")
                    appendLine("Embedding Dims: ${metadata.embeddingDimensions}")
                    appendLine("Parameters: ${metadata.parameterCount}")
                    appendLine("File Size: ${formatBytes(metadata.fileSizeBytes)}")
                }
            } catch (e: UniffiTemplateException) {
                errorMessage = e.message ?: "Unknown error"
                showError = true
            }
        }) {
            Text("Load Model Info")
        }

        Text(modelInfo)
    }

    if (showError) {
        AlertDialog(
            onDismissRequest = { showError = false },
            title = { Text("Error") },
            text = { Text(errorMessage) },
            confirmButton = {
                TextButton(onClick = { showError = false }) {
                    Text("OK")
                }
            }
        )
    }
}

fun formatBytes(bytes: ULong): String {
    val kb = bytes / 1024.0
    val mb = kb / 1024.0
    val gb = mb / 1024.0

    return when {
        gb >= 1.0 -> "${"%.2f".format(gb)} GB"
        mb >= 1.0 -> "${"%.2f".format(mb)} MB"
        kb >= 1.0 -> "${"%.2f".format(kb)} KB"
        else -> "$bytes bytes"
    }
}
```

---

### Desktop (JVM) Example

```kotlin
import uniffi.rust_multiplatform_template_lib.*
import java.nio.file.Paths

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        println("Usage: program <path-to-model.gguf>")
        return
    }

    val modelPath = args[0]

    println("Loading model metadata from: $modelPath")
    println()

    try {
        val metadata = loadModelMetadata(modelPath)

        println("✅ Model loaded successfully!")
        println()
        println("Model Information:")
        println("  Type:             ${metadata.modelType}")
        println("  Vocab Size:       ${metadata.vocabSize}")
        println("  Context Length:   ${metadata.contextLength}")
        println("  Embedding Dims:   ${metadata.embeddingDimensions}")
        println("  Parameters:       ${metadata.parameterCount}")
        println("  File Size:        ${formatBytes(metadata.fileSizeBytes)}")

    } catch (e: UniffiTemplateException.ModelNotFound) {
        System.err.println("❌ Error: Model file not found")
        System.err.println("   ${e.path}")
    } catch (e: UniffiTemplateException.InvalidModelFormat) {
        System.err.println("❌ Error: Invalid model format")
        System.err.println("   ${e.message}")
    } catch (e: UniffiTemplateException) {
        System.err.println("❌ Error: ${e.message}")
    }
}
```

Run:
```bash
./gradlew run --args="/path/to/model.gguf"
```

---

## Error Handling

All LLM functions can return errors. Handle them appropriately:

### Error Types

| Error | Description | When It Occurs |
|-------|-------------|----------------|
| `ModelNotFound` | File doesn't exist | Invalid path or file deleted |
| `InvalidModelFormat` | Not a valid GGUF file | Wrong file format or corrupted |
| `ModelLoadError` | Failed to load model | Permissions or I/O error |
| `IoError` | I/O operation failed | Disk read error |

### Example Error Handling

**Swift:**
```swift
do {
    let metadata = try loadModelMetadata(modelPath: path)
    // Use metadata
} catch let error as UniffiTemplateError {
    switch error {
    case .ModelNotFound(let path):
        print("Model not found: \(path)")
    case .InvalidModelFormat(let msg):
        print("Invalid format: \(msg)")
    case .ModelLoadError(let msg):
        print("Load error: \(msg)")
    default:
        print("Error: \(error)")
    }
}
```

**Kotlin:**
```kotlin
try {
    val metadata = loadModelMetadata(modelPath)
    // Use metadata
} catch (e: UniffiTemplateException.ModelNotFound) {
    println("Model not found: ${e.path}")
} catch (e: UniffiTemplateException.InvalidModelFormat) {
    println("Invalid format: ${e.message}")
} catch (e: UniffiTemplateException.ModelLoadError) {
    println("Load error: ${e.message}")
} catch (e: UniffiTemplateException) {
    println("Error: ${e.message}")
}
```

---

## Model Metadata Structure

```rust
pub struct ModelMetadata {
    pub model_type: String,           // e.g., "llama", "phi", "mistral"
    pub vocab_size: u32,               // e.g., 32000
    pub context_length: u32,           // e.g., 2048, 4096, 8192
    pub embedding_dimensions: u32,     // e.g., 4096
    pub parameter_count: String,       // e.g., "7B", "13B"
    pub file_size_bytes: u64,          // File size in bytes
}
```

### Field Descriptions

- **model_type**: Inferred from filename (llama, phi, mistral, gemma, etc.)
- **vocab_size**: Size of the tokenizer vocabulary (currently default: 32000)
- **context_length**: Maximum sequence length in tokens (currently default: 2048)
- **embedding_dimensions**: Size of token embeddings (currently default: 4096)
- **parameter_count**: Estimated from file size (< 1B, 1B, 3B, 7B, 13B, 30B, 70B+)
- **file_size_bytes**: Actual file size on disk

> **Note**: Currently, some values are estimated or use defaults. Future versions will parse actual GGUF metadata.

---

## Performance Considerations

### Loading Times

- **Metadata loading**: < 1ms (reads header only)
- **Backend detection**: < 1ms (platform detection)

### Memory Usage

- **Metadata loading**: < 1KB (no model weights loaded)
- **Backend detection**: Negligible

### Best Practices

1. **Load metadata first** before loading full model
2. **Validate file exists** before attempting load
3. **Check file size** to ensure sufficient storage
4. **Cache results** if checking same model multiple times
5. **Use async/background thread** for file I/O on mobile

---

## Troubleshooting

### iOS: "Model file not found"

**Problem**: File path incorrect or file not bundled
**Solution**:
```swift
// Verify file is in bundle
if let path = Bundle.main.path(forResource: "model", ofType: "gguf") {
    print("Found at: \(path)")
} else {
    print("Not found in bundle")
}
```

### Android: "Model file not found"

**Problem**: Assets not copied or incorrect path
**Solution**:
```kotlin
// List assets to verify
context.assets.list("models")?.forEach { fileName ->
    println("Found asset: models/$fileName")
}
```

### "Invalid model format"

**Problem**: File is not a valid GGUF file
**Solution**: Verify the first 4 bytes are "GGUF":
```bash
xxd -l 4 model.gguf
# Should show: 47 47 55 46  (GGUF in hex)
```

---

## Next Steps

After loading model metadata successfully, you're ready for:

1. **✅ Full model loading** - Load complete model into memory
2. **✅ Tokenization** - Convert text to/from tokens
3. **✅ Text generation** - Generate text completions
4. **✅ Streaming inference** - Real-time token generation

---

## Example Output

When you run the metadata loader, you'll see output like:

```
✅ Successfully loaded model metadata:

  Model Type:          llama
  Vocabulary Size:     32000
  Context Length:      2048
  Embedding Dimensions: 4096
  Parameter Count:     7B
  File Size:           4200000000 bytes (4.20 GB)
```

---

## Additional Resources

- **HuggingFace Candle**: https://github.com/huggingface/candle
- **GGUF Format**: https://github.com/ggerganov/ggml/blob/master/docs/gguf.md
- **Model Downloads**: https://huggingface.co/models?library=gguf
- **This Project**: https://github.com/eaceto/rust-multiplatform-template-lib

---

## Support

If you encounter issues:
1. Check this documentation
2. Verify model file is valid GGUF format
3. Check platform-specific troubleshooting sections
4. Open an issue on GitHub

Happy model loading! 🚀
