//! Core template functions for demonstration purposes

use crate::error::{TemplateError, TemplateResult, MAX_INPUT_SIZE};
use rand::Rng;

/// Returns true - a simple hello world function
///
/// # Returns
///
/// Always returns `true`
///
/// # Example
///
/// ```
/// use rust_multiplatform_template_lib::hello_world;
///
/// let result = hello_world();
/// assert_eq!(result, true);
/// ```
pub fn hello_world() -> bool {
    true
}

/// Echoes back the input string, or returns None if the string is empty
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
/// * `Ok(Some(String))` - The same string if not empty
/// * `Ok(None)` - If the input string is empty
/// * `Err(TemplateError::InputTooLarge)` - If input exceeds maximum size
///
/// # Example
///
/// ```
/// use rust_multiplatform_template_lib::echo;
///
/// let result = echo("Hello".to_string()).unwrap();
/// assert_eq!(result, Some("Hello".to_string()));
///
/// let empty = echo("".to_string()).unwrap();
/// assert_eq!(empty, None);
/// ```
///
/// # Security
///
/// This function enforces a maximum input size of 1MB to prevent
/// resource exhaustion. For production use, consider adjusting this
/// limit based on your application's requirements.
pub fn echo(input: String) -> TemplateResult<Option<String>> {
    // Validate input size
    let input_size = input.len();
    if input_size > MAX_INPUT_SIZE {
        return Err(TemplateError::InputTooLarge {
            size: input_size,
            max: MAX_INPUT_SIZE,
        });
    }

    // Return None for empty strings, Some for non-empty
    if input.is_empty() {
        Ok(None)
    } else {
        Ok(Some(input))
    }
}

/// Generates a random number between 0.0 and 1.0
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
/// let value = random();
/// assert!(value >= 0.0 && value < 1.0);
/// ```
pub fn random() -> f64 {
    let mut rng = rand::rng();
    rng.random()
}
