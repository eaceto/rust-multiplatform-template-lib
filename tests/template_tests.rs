use rust_multiplatform_template_lib::{
    echo, random, CancellationToken, EchoResult, TemplateConfig, TemplateError, MAX_INPUT_SIZE,
};
use std::sync::Arc;

#[tokio::test]
async fn test_echo_with_value() {
    let result = echo("test".to_string(), None).await.unwrap();
    assert!(result.is_some());
    let echo_result = result.unwrap();
    assert_eq!(echo_result.text, "test");
    assert_eq!(echo_result.length, 4);
}

#[tokio::test]
async fn test_echo_with_empty() {
    let result = echo("".to_string(), None).await.unwrap();
    assert!(result.is_none());
}

#[tokio::test]
async fn test_random_in_range() {
    for _ in 0..100 {
        let value = random().await;
        assert!((0.0..1.0).contains(&value));
    }
}

#[tokio::test]
async fn test_echo_with_whitespace() {
    let result = echo("   ".to_string(), None).await.unwrap();
    assert!(result.is_some());
    assert_eq!(result.unwrap().text, "   ");
}

#[tokio::test]
async fn test_echo_with_unicode() {
    let result = echo("Hello 世界 🌍".to_string(), None).await.unwrap();
    assert!(result.is_some());
    let echo_result = result.unwrap();
    assert_eq!(echo_result.text, "Hello 世界 🌍");
}

#[tokio::test]
async fn test_random_generates_different_values() {
    let value1 = random().await;
    let value2 = random().await;
    // Very unlikely to be equal
    assert_ne!(value1, value2);
}

#[tokio::test]
async fn test_echo_input_too_large() {
    // Create a string larger than MAX_INPUT_SIZE
    let large_input = "a".repeat(MAX_INPUT_SIZE + 1);
    let result = echo(large_input, None).await;

    assert!(result.is_err());
    match result {
        Err(TemplateError::InputTooLarge { size, max, hash }) => {
            assert_eq!(size, (MAX_INPUT_SIZE + 1) as u64);
            assert_eq!(max, MAX_INPUT_SIZE as u64);
            assert!(!hash.is_empty());
        }
        _ => panic!("Expected InputTooLarge error"),
    }
}

#[tokio::test]
async fn test_echo_at_max_size() {
    // Create a string exactly at MAX_INPUT_SIZE
    let max_input = "a".repeat(MAX_INPUT_SIZE);
    let result = echo(max_input.clone(), None).await.unwrap();

    assert!(result.is_some());
    assert_eq!(result.unwrap().text, max_input);
}

#[tokio::test]
async fn test_echo_just_under_max_size() {
    // Create a string just under MAX_INPUT_SIZE
    let input = "a".repeat(MAX_INPUT_SIZE - 1);
    let result = echo(input.clone(), None).await.unwrap();

    assert!(result.is_some());
    assert_eq!(result.unwrap().text, input);
}

#[tokio::test]
async fn test_echo_with_null_bytes() {
    // Test input with null bytes
    let input_with_null = "hello\0world".to_string();
    let result = echo(input_with_null, None).await;

    assert!(result.is_err());
    match result {
        Err(TemplateError::InvalidInput {
            error_message,
            input_preview,
        }) => {
            assert!(error_message.contains("null bytes"));
            assert!(input_preview.is_some());
        }
        _ => panic!("Expected InvalidInput error"),
    }
}

#[tokio::test]
async fn test_template_config() {
    let config = TemplateConfig::new(100, true);
    assert_eq!(config.max_input_size(), 100);
    assert!(config.enable_validation());

    // Test with valid input
    let result = config.validate_and_echo("test".to_string(), None).await.unwrap();
    assert!(result.is_some());
    assert_eq!(result.unwrap().text, "test");

    // Test with input exceeding config max size
    let large_input = "a".repeat(101);
    let result = config.validate_and_echo(large_input, None).await;
    assert!(result.is_err());
}

#[test]
fn test_cancellation_token() {
    let token = CancellationToken::new();
    assert!(!token.is_cancelled());

    token.cancel();
    assert!(token.is_cancelled());
}

#[tokio::test]
async fn test_echo_with_cancellation() {
    let token = Arc::new(CancellationToken::new());

    // Cancel immediately
    token.cancel();

    let result = echo("test".to_string(), Some(token)).await;

    assert!(result.is_err());
    match result {
        Err(TemplateError::OperationCancelled { operation }) => {
            assert_eq!(operation, "echo");
        }
        _ => panic!("Expected OperationCancelled error"),
    }
}

#[tokio::test]
async fn smoke_uniffi_api() {
    // echo should return EchoResult with metadata
    let input = "ping";
    let result = echo(input.to_string(), None).await;
    match result {
        Ok(Some(echo_result)) => {
            assert_eq!(echo_result.text, input, "echo should return the input text");
            assert_eq!(echo_result.length, 4);
            assert!(echo_result.timestamp > 0);
        }
        Ok(None) => panic!("echo returned None for non-empty input"),
        Err(err) => panic!("echo returned error: {:?}", err),
    }

    // random should return a value between 0.0 and 1.0
    let r = random().await;
    assert!(
        (0.0..1.0).contains(&r),
        "random should return a value in range [0.0, 1.0)"
    );
}
