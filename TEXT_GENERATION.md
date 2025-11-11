# Text Generation with GGUF Models

This guide explains how to use GGUF models for actual text generation (inference), beyond just loading metadata.

## Current Status

The library currently supports:
- ✅ **Backend Detection**: `get_backend_info()` - Detects Metal/CPU backends
- ✅ **Model Metadata**: `load_model_metadata()` - Reads model information from GGUF files
- ❌ **Text Generation**: Not yet implemented (see below for implementation path)

## Why Text Generation Isn't Implemented Yet

Text generation with GGUF models requires several complex components:

### 1. **Tokenizer**
- GGUF model files contain weights, but **tokenizers are usually separate**
- You need a `tokenizer.json` file (HuggingFace format) or tokenizer embedded in GGUF
- The tokenizer converts text → token IDs and token IDs → text

### 2. **Model Loading**
```rust
// Load the full quantized model (not just metadata)
use candle::quantized::gguf_file;
use candle_transformers::models::quantized_llama::ModelWeights;

let mut file = File::open("model.gguf")?;
let model = gguf_file::Content::read(&mut file)?;
let weights = ModelWeights::from_gguf(model, &mut file, &device)?;
```

### 3. **Text Generation Loop**
```rust
// Pseudo-code for generation
let tokens = tokenizer.encode(prompt)?;
for _ in 0..max_tokens {
    let input = Tensor::new(&tokens, &device)?;
    let logits = model.forward(&input, 0)?;
    let next_token = sample_token(&logits)?;  // Apply temperature, top-k, etc.
    tokens.push(next_token);
    if next_token == eos_token { break; }
}
let output_text = tokenizer.decode(&tokens)?;
```

### 4. **Sampling Strategy**
- Temperature scaling
- Top-K sampling
- Top-P (nucleus) sampling
- Repetition penalty

## Implementation Options

### Option A: Simple Wrapper (Recommended for Learning)

Create a basic `generate_text()` function following the Candle quantized example:

**Pros:**
- Full control over the implementation
- Learn how LLMs work internally
- Pure Rust, no C++ dependencies

**Cons:**
- Complex implementation (~500+ lines of code)
- Need to handle tokenizer separately
- Performance tuning required

**Example structure:**
```rust
pub fn generate_text(
    model_path: String,
    tokenizer_path: String,
    prompt: String,
    max_tokens: u32,
    temperature: f32,
) -> TemplateResult<String> {
    // 1. Load model
    // 2. Load tokenizer
    // 3. Encode prompt
    // 4. Generation loop
    // 5. Decode tokens
    // 6. Return text
}
```

### Option B: Use llama.cpp Bindings

Use `llama-cpp-2` Rust crate which wraps the C++ llama.cpp library:

**Pros:**
- Battle-tested inference engine
- Excellent performance
- Simpler API
- Active development

**Cons:**
- C++ dependency (harder to cross-compile for iOS/Android)
- Larger binary size
- More complex build process

**Example:**
```rust
use llama_cpp_2::context::LlamaContext;
use llama_cpp_2::model::LlamaModel;

pub fn generate_text(model_path: String, prompt: String) -> Result<String> {
    let model = LlamaModel::load_from_file(model_path, LlamaParams::default())?;
    let mut ctx = model.new_context(&mut LlamaContext::default())?;
    let result = ctx.completion(prompt, 100)?;
    Ok(result.content)
}
```

### Option C: Candle's Built-in Example (Current Approach)

Study and adapt Candle's quantized example:

```bash
# Clone Candle
git clone https://github.com/huggingface/candle.git
cd candle

# Run the quantized example
cargo run --example quantized --release -- \
    --model path/to/model.gguf \
    --prompt "Hello, my name is" \
    --sample-len 50
```

Then adapt the code from `candle-examples/examples/quantized/main.rs` to your library.

## Minimal Working Example

Here's the simplest path to get text generation working:

### Step 1: Download a Model + Tokenizer

```bash
# Download TinyLlama GGUF model
wget https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf

# Download tokenizer (from base model)
wget https://huggingface.co/TinyLlama/TinyLlama-1.1B-Chat-v1.0/resolve/main/tokenizer.json
```

### Step 2: Add Dependencies

Update `Cargo.toml`:
```toml
[dependencies]
candle-core = "0.9.1"
candle-transformers = "0.9.1"
candle-nn = "0.9.1"
tokenizers = "0.21"
```

### Step 3: Implement Generation (Simplified)

Create `src/generation.rs`:

```rust
use candle::{Device, Tensor};
use candle::quantized::gguf_file;
use candle_transformers::models::quantized_llama::ModelWeights;
use candle_transformers::generation::{LogitsProcessor, Sampling};
use tokenizers::Tokenizer;
use std::fs::File;

pub fn generate_text(
    model_path: String,
    tokenizer_path: String,
    prompt: String,
    max_tokens: usize,
) -> crate::TemplateResult<String> {
    // 1. Setup device
    let device = Device::Cpu;  // Or Device::Metal for Apple Silicon

    // 2. Load model
    let mut file = File::open(&model_path)
        .map_err(|e| crate::TemplateError::ModelLoadError(e.to_string()))?;
    let model = gguf_file::Content::read(&mut file)
        .map_err(|e| crate::TemplateError::InvalidModelFormat(e.to_string()))?;
    let weights = ModelWeights::from_gguf(model, &mut file, &device)
        .map_err(|e| crate::TemplateError::ModelLoadError(e.to_string()))?;

    // 3. Load tokenizer
    let tokenizer = Tokenizer::from_file(&tokenizer_path)
        .map_err(|e| crate::TemplateError::ModelLoadError(e.to_string()))?;

    // 4. Encode prompt
    let tokens = tokenizer.encode(prompt, true)
        .map_err(|e| crate::TemplateError::InvalidInput(e.to_string()))?
        .get_ids()
        .to_vec();

    // 5. Generate tokens
    let mut all_tokens = tokens.clone();
    let mut logits_processor = LogitsProcessor::from_sampling(
        299792458,  // seed
        Sampling::All { temperature: 0.8 }
    );

    for _ in 0..max_tokens {
        let input = Tensor::new(all_tokens.as_slice(), &device)
            .map_err(|e| crate::TemplateError::ModelLoadError(e.to_string()))?
            .unsqueeze(0)
            .map_err(|e| crate::TemplateError::ModelLoadError(e.to_string()))?;

        let logits = weights.forward(&input, 0)
            .map_err(|e| crate::TemplateError::ModelLoadError(e.to_string()))?;

        let next_token = logits_processor.sample(&logits.squeeze(0)?)
            .map_err(|e| crate::TemplateError::ModelLoadError(e.to_string()))?;

        all_tokens.push(next_token);

        // Check for EOS token (typically 2 for Llama models)
        if next_token == 2 {
            break;
        }
    }

    // 6. Decode output
    let output = tokenizer.decode(&all_tokens[tokens.len()..], true)
        .map_err(|e| crate::TemplateError::ModelLoadError(e.to_string()))?;

    Ok(output)
}
```

### Step 4: Expose via UniFFI

Add to `src/uniffi_wrapper.rs`:
```rust
#[uniffi::export]
pub fn generate_text(
    model_path: String,
    tokenizer_path: String,
    prompt: String,
    max_tokens: u32,
) -> Result<String, UniffiTemplateError> {
    generation::generate_text(model_path, tokenizer_path, prompt, max_tokens as usize)
        .map_err(Into::into)
}
```

### Step 5: Use in iOS

```swift
let modelPath = Bundle.main.path(forResource: "tinyllama", ofType: "gguf")!
let tokenizerPath = Bundle.main.path(forResource: "tokenizer", ofType: "json")!

let result = try generateText(
    modelPath: modelPath,
    tokenizerPath: tokenizerPath,
    prompt: "The capital of France is",
    maxTokens: 20
)

print(result)  // " Paris. The capital of Germany is Berlin..."
```

## Performance Considerations

### Model Size vs Device
- **< 1GB models**: Work well on mobile (TinyLlama, Phi-2)
- **1-4GB models**: Need good device (Llama-3-8B quantized)
- **> 4GB models**: Desktop/server only

### Backend Selection
```rust
#[cfg(target_os = "macos")]
let device = Device::new_metal(0)?;  // Metal for M1/M2/M3

#[cfg(not(target_os = "macos"))]
let device = Device::Cpu;  // CPU fallback
```

### Memory Management
- Keep model loaded between generations (don't reload each time)
- Use model quantization (Q4_K_M format recommended)
- Consider streaming output token-by-token

## Recommended Next Steps

1. **Test with Candle's quantized example first**:
   ```bash
   cd /tmp/candle-examples
   cargo run --example quantized --release -- \
       --model ~/path/to/model.gguf \
       --prompt "Write a hello world in Rust"
   ```

2. **Extract the core generation logic** from the example and adapt it to your library

3. **Start with CPU backend** to avoid platform-specific issues

4. **Add Metal backend** for iOS/macOS after CPU works

5. **Handle tokenizer bundling** - either embed in GGUF or bundle separately

## Resources

- [Candle Quantized Example](https://github.com/huggingface/candle/blob/main/candle-examples/examples/quantized/main.rs)
- [Candle Documentation](https://huggingface.github.io/candle/)
- [GGUF Models on HuggingFace](https://huggingface.co/models?library=gguf)
- [Tokenizers Documentation](https://huggingface.co/docs/tokenizers/index)

## Limitations & Challenges

1. **Tokenizer Format**: Most GGUF models don't include tokenizers - you need to download separately
2. **Context Length**: Limited by device memory (typically 2K-4K tokens on mobile)
3. **Speed**: CPU inference is slow (~1-5 tokens/sec), Metal much faster (~20-50 tokens/sec)
4. **Model Compatibility**: Not all GGUF models work with Candle - test first
5. **Binary Size**: Full generation adds ~50MB to your app

## Conclusion

The current library provides the foundation (metadata loading, backend detection). **Full text generation requires significant additional work** - approximately 500-1000 lines of carefully written Rust code.

For production use, consider:
- **llama.cpp bindings** for best performance and compatibility
- **Candle quantized example** for pure Rust solution
- **Cloud API** (OpenAI, Anthropic) for simplicity if on-device is not required

The metadata loading you have now is perfect for:
- Validating models before downloading
- Showing model info in UI
- Checking compatibility
- Building model management features

For actual inference, you'll need to choose one of the implementation options above.
