//! # Rust Multiplatform Template Library
//!
//! A template library demonstrating how to create Rust code that can be embedded
//! in multiple platforms: iOS, macOS, Android, and JVM.
//!
//! This template uses UniFFI to generate language bindings for Swift and Kotlin,
//! allowing seamless integration with native mobile and desktop applications.
//!
//! ## Functions (All Async)
//!
//! - `echo(input, token)`: Returns the input string with metadata, or None if empty (async with cancellation)
//! - `random()`: Returns a random double between 0.0 and 1.0 (async)
//!
//! ## Types
//!
//! - `EchoResult`: Rich result type with text, length, timestamp, and hash
//! - `TemplateConfig`: Configuration object for template operations
//! - `CancellationToken`: Token for cancelling async operations
//!
//! ## Error Handling
//!
//! Functions that can fail return `Result<T, TemplateError>`. See the `error` module
//! for details on error types and handling.

mod error;
mod template;

// Export the public API
pub use crate::error::{TemplateError, TemplateResult, DEFAULT_MAX_SIZE, MAX_INPUT_SIZE};
pub use crate::template::{echo, random, CancellationToken, EchoResult, TemplateConfig};

// Include the UDL file for UniFFI
uniffi::include_scaffolding!("template");
