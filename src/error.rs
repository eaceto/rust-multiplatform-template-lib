//! Error types for the template library

use thiserror::Error;

/// Errors that can occur when using the template library
#[derive(Debug, Error, Clone, PartialEq)]
pub enum TemplateError {
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

/// Maximum allowed input size (1MB)
pub const MAX_INPUT_SIZE: usize = 1_000_000;

/// Result type for template operations
pub type TemplateResult<T> = Result<T, TemplateError>;
