//! Example demonstrating model metadata loading
//!
//! This example shows how to load metadata from a GGUF model file

use rust_multiplatform_template_lib::load_model_metadata;

fn main() {
    println!("=== Model Metadata Loading Demo ===\n");

    // Test with the minimal test file
    let test_model = "test-models/tinyllama-test.gguf";

    println!("Loading metadata from: {}\n", test_model);

    match load_model_metadata(test_model.to_string()) {
        Ok(metadata) => {
            println!("✅ Successfully loaded model metadata:\n");
            println!("  Model Type:          {}", metadata.model_type);
            println!("  Vocabulary Size:     {}", metadata.vocab_size);
            println!("  Context Length:      {}", metadata.context_length);
            println!("  Embedding Dimensions: {}", metadata.embedding_dimensions);
            println!("  Parameter Count:     {}", metadata.parameter_count);
            println!("  File Size:           {} bytes ({:.2} KB)",
                metadata.file_size_bytes,
                metadata.file_size_bytes as f64 / 1024.0
            );
        }
        Err(e) => {
            eprintln!("❌ Error loading model metadata:");
            eprintln!("   {}", e);
            std::process::exit(1);
        }
    }

    println!("\n✅ Model metadata test complete!");

    // Test with non-existent file
    println!("\n--- Testing error handling ---\n");
    let fake_model = "nonexistent.gguf";
    println!("Attempting to load: {}", fake_model);

    match load_model_metadata(fake_model.to_string()) {
        Ok(_) => println!("Unexpected success"),
        Err(e) => println!("Expected error: {}", e),
    }
}
