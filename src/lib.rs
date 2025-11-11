//! # Rust Multiplatform LLM Library
//!
//! A Rust library for LLM (Large Language Model) inference that can be embedded
//! in multiple platforms: iOS, macOS, Android, and JVM.
//!
//! This library uses UniFFI to generate language bindings for Swift and Kotlin,
//! allowing seamless integration with native mobile and desktop applications.
//!
//! Powered by HuggingFace Candle for efficient on-device LLM inference.
//!
//! ## Functions
//!
//! ### LLM Functions (Candle-based)
//! - `get_backend_info()`: Returns information about available compute backends
//! - `load_model_metadata(path)`: Loads metadata from a GGUF model file
//!
//! ## Error Handling
//!
//! Functions that can fail return `Result<T, TemplateError>`. See the `error` module
//! for details on error types and handling.

mod error;
mod llama;

// UniFFI bindings module (for Swift/Kotlin)
mod uniffi_wrapper;

// Export the public API
pub use crate::error::{TemplateError, TemplateResult};
pub use crate::llama::{get_backend_info, load_model_metadata, ModelMetadata};

// Setup UniFFI scaffolding at crate root
uniffi::setup_scaffolding!();
