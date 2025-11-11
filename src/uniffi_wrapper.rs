//! UniFFI wrapper for generating Swift and Kotlin bindings
//!
//! This module wraps the core Rust functions in a way that UniFFI can understand
//! and generate appropriate bindings for Swift (iOS/macOS) and Kotlin (Android/JVM).

use crate::{error::TemplateError, llama};

/// Metadata information about a model (UniFFI-compatible)
#[derive(Debug, Clone, uniffi::Record)]
pub struct UniffiModelMetadata {
    pub model_type: String,
    pub vocab_size: u32,
    pub context_length: u32,
    pub embedding_dimensions: u32,
    pub parameter_count: String,
    pub file_size_bytes: u64,
}

impl From<crate::llama::ModelMetadata> for UniffiModelMetadata {
    fn from(metadata: crate::llama::ModelMetadata) -> Self {
        UniffiModelMetadata {
            model_type: metadata.model_type,
            vocab_size: metadata.vocab_size,
            context_length: metadata.context_length,
            embedding_dimensions: metadata.embedding_dimensions,
            parameter_count: metadata.parameter_count,
            file_size_bytes: metadata.file_size_bytes,
        }
    }
}

/// Error type exposed to Swift/Kotlin
#[derive(Debug, thiserror::Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum UniffiTemplateError {
    /// Model file not found
    #[error("Model file not found: {path}")]
    ModelNotFound { path: String },

    /// Invalid model format
    #[error("Invalid model format: {message}")]
    InvalidModelFormat { message: String },

    /// Model loading failed
    #[error("Failed to load model: {message}")]
    ModelLoadError { message: String },

    /// IO error
    #[error("IO error: {message}")]
    IoError { message: String },

    /// Generic error
    #[error("{message}")]
    Generic { message: String },
}

impl From<TemplateError> for UniffiTemplateError {
    fn from(err: TemplateError) -> Self {
        match err {
            TemplateError::ModelNotFound(path) => UniffiTemplateError::ModelNotFound { path },
            TemplateError::InvalidModelFormat(msg) => {
                UniffiTemplateError::InvalidModelFormat { message: msg }
            }
            TemplateError::ModelLoadError(msg) => UniffiTemplateError::ModelLoadError { message: msg },
            TemplateError::IoError(msg) => UniffiTemplateError::IoError { message: msg },
            TemplateError::InputTooLarge { size, max } => UniffiTemplateError::Generic {
                message: format!("Input too large: {} bytes exceeds maximum of {} bytes", size, max),
            },
            TemplateError::InvalidInput(msg) => UniffiTemplateError::Generic { message: msg },
        }
    }
}

// ============================================================================
// LLM Functions (Candle-based)
// ============================================================================

/// Returns information about the available backend for LLM inference
///
/// Detects which compute backends are available (Metal, CUDA, CPU, etc.)
#[uniffi::export]
pub fn get_backend_info() -> Result<String, UniffiTemplateError> {
    llama::get_backend_info().map_err(Into::into)
}

/// Loads metadata from a GGUF model file
///
/// Reads metadata from a GGUF format model file without loading the full model.
/// Useful for validating model files before loading.
#[uniffi::export]
pub fn load_model_metadata(model_path: String) -> Result<UniffiModelMetadata, UniffiTemplateError> {
    llama::load_model_metadata(model_path)
        .map(Into::into)
        .map_err(Into::into)
}
