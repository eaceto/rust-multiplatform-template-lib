//! Error types for the LLM library

use thiserror::Error;

/// Errors that can occur when using the LLM library
#[derive(Debug, Error, Clone, PartialEq)]
pub enum TemplateError {
    /// Model file not found
    #[error("Model file not found: {0}")]
    ModelNotFound(String),

    /// Invalid model format
    #[error("Invalid model format: {0}")]
    InvalidModelFormat(String),

    /// Model loading failed
    #[error("Failed to load model: {0}")]
    ModelLoadError(String),

    /// IO error
    #[error("IO error: {0}")]
    IoError(String),

    // Legacy errors - kept for backward compatibility
    /// Input string exceeds maximum allowed size
    #[error("Input too large: {size} bytes exceeds maximum of {max} bytes")]
    InputTooLarge {
        /// The size of the input that was provided
        size: usize,
        /// The maximum allowed size
        max: usize,
    },

    /// Input validation failed
    #[error("Invalid input: {0}")]
    InvalidInput(String),
}

/// Result type for operations
pub type TemplateResult<T> = Result<T, TemplateError>;
