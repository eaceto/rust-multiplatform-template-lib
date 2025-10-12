use rust_multiplatform_template_lib::{echo, hello_world, random, TemplateError, MAX_INPUT_SIZE};

#[test]
fn test_hello_world() {
    assert_eq!(hello_world(), true);
}

#[test]
fn test_echo_with_value() {
    let result = echo("test".to_string()).unwrap();
    assert_eq!(result, Some("test".to_string()));
}

#[test]
fn test_echo_with_empty() {
    let result = echo("".to_string()).unwrap();
    assert_eq!(result, None);
}

#[test]
fn test_random_in_range() {
    for _ in 0..100 {
        let value = random();
        assert!(value >= 0.0 && value < 1.0);
    }
}

#[test]
fn test_echo_with_whitespace() {
    let result = echo("   ".to_string()).unwrap();
    assert_eq!(result, Some("   ".to_string()));
}

#[test]
fn test_echo_with_unicode() {
    let result = echo("Hello 世界 🌍".to_string()).unwrap();
    assert_eq!(result, Some("Hello 世界 🌍".to_string()));
}

#[test]
fn test_random_generates_different_values() {
    let value1 = random();
    let value2 = random();
    // Very unlikely to be equal
    assert_ne!(value1, value2);
}

#[test]
fn test_echo_input_too_large() {
    // Create a string larger than MAX_INPUT_SIZE
    let large_input = "a".repeat(MAX_INPUT_SIZE + 1);
    let result = echo(large_input);

    assert!(result.is_err());
    match result {
        Err(TemplateError::InputTooLarge { size, max }) => {
            assert_eq!(size, MAX_INPUT_SIZE + 1);
            assert_eq!(max, MAX_INPUT_SIZE);
        }
        _ => panic!("Expected InputTooLarge error"),
    }
}

#[test]
fn test_echo_at_max_size() {
    // Create a string exactly at MAX_INPUT_SIZE
    let max_input = "a".repeat(MAX_INPUT_SIZE);
    let result = echo(max_input.clone()).unwrap();

    assert_eq!(result, Some(max_input));
}

#[test]
fn test_echo_just_under_max_size() {
    // Create a string just under MAX_INPUT_SIZE
    let input = "a".repeat(MAX_INPUT_SIZE - 1);
    let result = echo(input.clone()).unwrap();

    assert_eq!(result, Some(input));
}
