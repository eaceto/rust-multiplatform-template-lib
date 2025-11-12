//! Error types for the template library

use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};
use thiserror::Error;

/// Errors that can occur when using the template library
#[derive(Debug, Error, Clone, PartialEq)]
pub enum TemplateError {
    /// Input string exceeds maximum allowed size
    #[error("Input too large: {size} bytes exceeds maximum of {max} bytes (hash: {hash})")]
    InputTooLarge {
        /// The size of the input that was provided
        size: u64,
        /// The maximum allowed size
        max: u64,
        /// Hash of the input for debugging
        hash: String,
    },

    /// Input validation failed
    #[error("Invalid input: {error_message}")]
    InvalidInput {
        /// Error message
        error_message: String,
        /// Preview of the input (first 50 chars)
        input_preview: Option<String>,
    },

    /// Operation was cancelled
    #[error("Operation cancelled: {operation}")]
    OperationCancelled {
        /// Name of the operation that was cancelled
        operation: String,
    },
}

impl TemplateError {
    /// Create InputTooLarge error with hash
    pub fn input_too_large(size: usize, max: usize, input: &str) -> Self {
        let hash = calculate_hash(input);
        Self::InputTooLarge {
            size: size as u64,
            max: max as u64,
            hash: format!("{:x}", hash),
        }
    }

    /// Create InvalidInput error with preview
    pub fn invalid_input(error_message: String, input: Option<&str>) -> Self {
        let preview = input.map(|s| {
            if s.len() > 50 {
                format!("{}...", &s[..50])
            } else {
                s.to_string()
            }
        });
        Self::InvalidInput {
            error_message,
            input_preview: preview,
        }
    }

    /// Create OperationCancelled error
    pub fn operation_cancelled(operation: &str) -> Self {
        Self::OperationCancelled {
            operation: operation.to_string(),
        }
    }
}

/// Calculate hash for debugging purposes
fn calculate_hash(input: &str) -> u64 {
    let mut hasher = DefaultHasher::new();
    input.hash(&mut hasher);
    hasher.finish()
}

/// Maximum allowed input size (1MB)
pub const MAX_INPUT_SIZE: usize = 1_000_000;

/// Default maximum size
pub const DEFAULT_MAX_SIZE: usize = 1_000_000;

/// Result type for template operations
pub type TemplateResult<T> = Result<T, TemplateError>;
