//! Core template functions for demonstration purposes

use crate::error::{TemplateError, TemplateResult, MAX_INPUT_SIZE};
use rand::Rng;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

/// Result of an echo operation with metadata
#[derive(Debug, Clone, PartialEq)]
pub struct EchoResult {
    /// The echoed text
    pub text: String,
    /// Length of the text
    pub length: u32,
    /// Unix timestamp when the operation completed
    pub timestamp: u64,
    /// Optional hash for debugging
    pub hash: Option<String>,
}

impl EchoResult {
    /// Create a new EchoResult
    pub fn new(text: String) -> Self {
        let length = text.len() as u32;
        let timestamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs();

        Self {
            text,
            length,
            timestamp,
            hash: None,
        }
    }

    /// Create with hash for debugging
    pub fn with_hash(mut self, hash: String) -> Self {
        self.hash = Some(hash);
        self
    }
}

/// Configuration for template operations
#[derive(Debug, Clone)]
pub struct TemplateConfig {
    /// Maximum input size allowed
    max_input_size: u64,
    /// Whether to enable validation
    enable_validation: bool,
}

impl TemplateConfig {
    /// Create a new TemplateConfig
    pub fn new(max_input_size: u64, enable_validation: bool) -> Self {
        Self {
            max_input_size,
            enable_validation,
        }
    }

    /// Get the maximum input size
    pub fn max_input_size(&self) -> u64 {
        self.max_input_size
    }

    /// Check if validation is enabled
    pub fn enable_validation(&self) -> bool {
        self.enable_validation
    }

    /// Validate and echo input using this configuration (async)
    pub async fn validate_and_echo(
        &self,
        input: String,
        token: Option<Arc<CancellationToken>>,
    ) -> TemplateResult<Option<EchoResult>> {
        // Check cancellation
        if let Some(ref t) = token {
            if t.is_cancelled() {
                return Err(TemplateError::operation_cancelled("validate_and_echo"));
            }
        }

        tokio::task::yield_now().await;

        // Check cancellation again
        if let Some(ref t) = token {
            if t.is_cancelled() {
                return Err(TemplateError::operation_cancelled("validate_and_echo"));
            }
        }

        validate_and_echo_internal(&input, self.max_input_size as usize, self.enable_validation)
    }
}

/// Cancellation token for async operations
#[derive(Debug, Clone)]
pub struct CancellationToken {
    cancelled: Arc<AtomicBool>,
}

impl CancellationToken {
    /// Create a new cancellation token
    pub fn new() -> Self {
        Self {
            cancelled: Arc::new(AtomicBool::new(false)),
        }
    }

    /// Cancel the operation
    pub fn cancel(&self) {
        self.cancelled.store(true, Ordering::Release);
    }

    /// Check if the operation is cancelled
    pub fn is_cancelled(&self) -> bool {
        self.cancelled.load(Ordering::Acquire)
    }
}

impl Default for CancellationToken {
    fn default() -> Self {
        Self {
            cancelled: Arc::new(AtomicBool::new(false)),
        }
    }
}

/// Validates input for common issues
fn validate_input(input: &str) -> TemplateResult<()> {
    // Check for null bytes
    if input.contains('\0') {
        return Err(TemplateError::invalid_input(
            "Input contains null bytes".to_string(),
            Some(input),
        ));
    }

    // Validate UTF-8 (already validated by Rust, but check boundaries)
    if !input.is_empty() && !input.is_char_boundary(input.len()) {
        return Err(TemplateError::invalid_input(
            "Invalid UTF-8 sequence".to_string(),
            Some(input),
        ));
    }

    Ok(())
}

/// Internal implementation of echo with validation
fn validate_and_echo_internal(
    input: &str,
    max_size: usize,
    enable_validation: bool,
) -> TemplateResult<Option<EchoResult>> {
    // Validate input size
    let input_size = input.len();
    if input_size > max_size {
        return Err(TemplateError::input_too_large(input_size, max_size, input));
    }

    // Optional validation
    if enable_validation {
        validate_input(input)?;
    }

    // Return None for empty strings
    if input.is_empty() {
        return Ok(None);
    }

    // Create result with metadata
    let result = EchoResult::new(input.to_string());
    Ok(Some(result))
}

/// Echoes back the input string with metadata, or returns None if the string is empty
///
/// This function validates the input size to prevent resource exhaustion attacks.
/// The maximum allowed input size is 1MB (1,000,000 bytes).
///
/// # Arguments
///
/// * `input` - The string to echo back
///
/// # Returns
///
/// * `Ok(Some(EchoResult))` - The echoed text with metadata if not empty
/// * `Ok(None)` - If the input string is empty
/// * `Err(TemplateError::InputTooLarge)` - If input exceeds maximum size
/// * `Err(TemplateError::InvalidInput)` - If input contains invalid data
///
/// # Example
///
/// ```
/// use rust_multiplatform_template_lib::echo;
///
/// # tokio_test::block_on(async {
/// let result = echo("Hello".to_string(), None).await.unwrap();
/// assert!(result.is_some());
/// let echo_result = result.unwrap();
/// assert_eq!(echo_result.text, "Hello");
/// assert_eq!(echo_result.length, 5);
///
/// let empty = echo("".to_string(), None).await.unwrap();
/// assert!(empty.is_none());
/// # })
/// ```
///
/// # Security
///
/// This function enforces a maximum input size of 1MB to prevent
/// resource exhaustion and validates input for null bytes.
pub async fn echo(
    input: String,
    token: Option<Arc<CancellationToken>>,
) -> TemplateResult<Option<EchoResult>> {
    // Check cancellation before starting
    if let Some(ref t) = token {
        if t.is_cancelled() {
            return Err(TemplateError::operation_cancelled("echo"));
        }
    }

    // Simulate some async work
    tokio::task::yield_now().await;

    // Check cancellation during processing
    if let Some(ref t) = token {
        if t.is_cancelled() {
            return Err(TemplateError::operation_cancelled("echo"));
        }
    }

    // Perform the actual echo operation
    validate_and_echo_internal(&input, MAX_INPUT_SIZE, true)
}

/// Generates a random number between 0.0 and 1.0 (async)
///
/// Uses thread-local RNG for better performance.
///
/// # Returns
///
/// A random `f64` value in the range [0.0, 1.0)
///
/// # Example
///
/// ```
/// use rust_multiplatform_template_lib::random;
///
/// # tokio_test::block_on(async {
/// let value = random().await;
/// assert!((0.0..1.0).contains(&value));
/// # })
/// ```
pub async fn random() -> f64 {
    tokio::task::yield_now().await;
    rand::rng().random()
}
