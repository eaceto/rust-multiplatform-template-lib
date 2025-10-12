//! # Rust Multiplatform Template Library
//!
//! A template library demonstrating how to create Rust code that can be embedded
//! in multiple platforms: iOS, macOS, Android, and JVM.
//!
//! This template uses UniFFI to generate language bindings for Swift and Kotlin,
//! allowing seamless integration with native mobile and desktop applications.
//!
//! ## Functions
//!
//! - `hello_world()`: Returns a boolean true value
//! - `echo(input)`: Returns the input string, or None if empty (with size validation)
//! - `random()`: Returns a random double between 0.0 and 1.0
//!
//! ## Error Handling
//!
//! Functions that can fail return `Result<T, TemplateError>`. See the `error` module
//! for details on error types and handling.

mod error;
mod template;

// UniFFI bindings module (for Swift/Kotlin)
mod uniffi_wrapper;

// Export the public API
pub use crate::error::{TemplateError, TemplateResult, MAX_INPUT_SIZE};
pub use crate::template::{echo, hello_world, random};

// Setup UniFFI scaffolding at crate root
uniffi::setup_scaffolding!();
