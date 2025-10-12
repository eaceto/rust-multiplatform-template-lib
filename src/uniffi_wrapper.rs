//! UniFFI wrapper for generating Swift and Kotlin bindings
//!
//! This module wraps the core Rust functions in a way that UniFFI can understand
//! and generate appropriate bindings for Swift (iOS/macOS) and Kotlin (Android/JVM).

use crate::{error::TemplateError, template};

/// Error type exposed to Swift/Kotlin
#[derive(Debug, thiserror::Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum UniffiTemplateError {
    /// Input string exceeds maximum allowed size
    #[error("Input too large: {size} bytes exceeds maximum of {max} bytes")]
    InputTooLarge { size: u64, max: u64 },

    /// Input validation failed
    #[error("Invalid input: {message}")]
    InvalidInput { message: String },
}

impl From<TemplateError> for UniffiTemplateError {
    fn from(err: TemplateError) -> Self {
        match err {
            TemplateError::InputTooLarge { size, max } => UniffiTemplateError::InputTooLarge {
                size: size as u64,
                max: max as u64,
            },
            TemplateError::InvalidInput(msg) => UniffiTemplateError::InvalidInput { message: msg },
        }
    }
}

/// Returns true - a simple hello world function
#[uniffi::export]
pub fn hello_world() -> bool {
    template::hello_world()
}

/// Echoes back the input string, or returns None if the string is empty
///
/// Validates input size (max 1MB) to prevent resource exhaustion.
#[uniffi::export]
pub fn echo(input: String) -> Result<Option<String>, UniffiTemplateError> {
    template::echo(input).map_err(Into::into)
}

/// Generates a random number between 0.0 and 1.0
#[uniffi::export]
pub fn random() -> f64 {
    template::random()
}
