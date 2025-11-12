# UniFFI UDL Guide

This guide explains how to use and modify the UniFFI Interface Definition Language (UDL) file in this project.

## Table of Contents

- [What is UDL?](#what-is-udl)
- [Why Use UDL?](#why-use-udl)
- [UDL File Location](#udl-file-location)
- [Basic Syntax](#basic-syntax)
- [Adding New Functions](#adding-new-functions)
- [Working with Types](#working-with-types)
- [Error Handling](#error-handling)
- [Async Functions](#async-functions)
- [Objects and Interfaces](#objects-and-interfaces)
- [Complete Example](#complete-example)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## What is UDL?

UDL (Uniform Definition Language) is UniFFI's interface definition language. It's a declarative way to define your Rust API that will be exposed to Swift and Kotlin.

Instead of using Rust attributes like `#[uniffi::export]`, you write a `.udl` file that describes your API, and UniFFI generates all the binding code automatically.

---

## Why Use UDL?

**Advantages of UDL:**

1. **Clear API Contract**: The UDL file serves as a clear, language-agnostic contract
2. **Better Documentation**: Easier to understand the public API at a glance
3. **Type Safety**: Explicit type definitions catch errors early
4. **Separation of Concerns**: Keep binding definitions separate from implementation
5. **Team Collaboration**: Non-Rust developers can understand the API

**When to use UDL vs Proc Macros:**

- **Use UDL** for:
  - Complex APIs with many types
  - Team projects where API clarity is important
  - When you want a single source of truth for the API

- **Use Proc Macros** (`#[uniffi::export]`) for:
  - Simple, small libraries
  - Rapid prototyping
  - When you prefer keeping everything in Rust

---

## UDL File Location

In this project, the UDL file is located at:

```
src/template.udl
```

The build system (`build.rs`) reads this file and generates the necessary scaffolding code.

---

## Basic Syntax

### Namespace

Every UDL file must have a namespace that defines top-level functions:

```udl
namespace template {
    
    string echo(string input);
}
```

This generates:
- **Swift**: `random()` and `echo(input:)`
- **Kotlin**: `random()` and `echo(input)`

### Comments

```udl
// Single-line comment

// Multi-line example:
// This function does something
// important
boolean my_function();
```

---

## Adding New Functions

### Step 1: Define in UDL

Add your function to the namespace block in `src/template.udl`:

```udl
namespace template {
    // Existing functions...

    // Your new function
    u32 calculate_sum(u32 a, u32 b);
}
```

### Step 2: Implement in Rust

Add the implementation in `src/template.rs`:

```rust
/// Calculate the sum of two numbers
pub fn calculate_sum(a: u32, b: u32) -> u32 {
    a + b
}
```

### Step 3: Export in lib.rs

Add to the public API in `src/lib.rs`:

```rust
pub use crate::template::calculate_sum;
```

### Step 4: Rebuild

```bash
cargo build --lib
./scripts/build-apple.sh    # For iOS/macOS
./scripts/build-kotlin.sh   # For Android/JVM
```

---

## Working with Types

### Primitive Types

| UDL Type | Rust Type | Swift Type | Kotlin Type |
|----------|-----------|------------|-------------|
| `boolean` | `bool` | `Bool` | `Boolean` |
| `string` | `String` | `String` | `String` |
| `u8`, `u16`, `u32`, `u64` | `u8`, `u16`, `u32`, `u64` | `UInt8`, `UInt16`, `UInt32`, `UInt64` | `UByte`, `UShort`, `UInt`, `ULong` |
| `i8`, `i16`, `i32`, `i64` | `i8`, `i16`, `i32`, `i64` | `Int8`, `Int16`, `Int32`, `Int64` | `Byte`, `Short`, `Int`, `Long` |
| `f32`, `f64` | `f32`, `f64` | `Float`, `Double` | `Float`, `Double` |

### Optional Types

Use `?` for optional values:

```udl
namespace template {
    string? get_optional_value();
}
```

Rust implementation:

```rust
pub fn get_optional_value() -> Option<String> {
    Some("value".to_string())
}
```

### Dictionary (Struct)

Define a struct with the `dictionary` keyword:

```udl
dictionary Person {
    string name;
    u32 age;
    string? email;  // Optional field
};

namespace template {
    Person create_person(string name, u32 age);
}
```

Rust implementation:

```rust
#[derive(Debug, Clone)]
pub struct Person {
    pub name: String,
    pub age: u32,
    pub email: Option<String>,
}

pub fn create_person(name: String, age: u32) -> Person {
    Person {
        name,
        age,
        email: None,
    }
}
```

### Enum

```udl
enum Status {
    "Pending",
    "Active",
    "Completed",
};

namespace template {
    Status get_status();
}
```

Rust:

```rust
#[derive(Debug, Clone, PartialEq)]
pub enum Status {
    Pending,
    Active,
    Completed,
}

pub fn get_status() -> Status {
    Status::Active
}
```

---

## Error Handling

### Defining Errors

Errors are defined as interfaces with the `[Error]` attribute:

```udl
[Error]
interface MyError {
    InvalidInput(string message);
    NotFound(u64 id);
    Timeout();
};
```

### Using Errors in Functions

```udl
namespace template {
    [Throws=MyError]
    string process_data(string input);
}
```

### Rust Implementation

```rust
#[derive(Debug, thiserror::Error, Clone, PartialEq)]
pub enum MyError {
    #[error("Invalid input: {message}")]
    InvalidInput { message: String },

    #[error("Not found: {id}")]
    NotFound { id: u64 },

    #[error("Operation timed out")]
    Timeout,
}

pub fn process_data(input: String) -> Result<String, MyError> {
    if input.is_empty() {
        return Err(MyError::InvalidInput {
            message: "Input cannot be empty".to_string(),
        });
    }
    Ok(input.to_uppercase())
}
```

### Swift Usage

```swift
do {
    let result = try processData(input: "test")
    print(result)
} catch let error as MyError {
    switch error {
    case .InvalidInput(let message):
        print("Invalid: \(message)")
    case .NotFound(let id):
        print("Not found: \(id)")
    case .Timeout:
        print("Timeout!")
    }
}
```

### Kotlin Usage

```kotlin
try {
    val result = processData("test")
    println(result)
} catch (e: MyException) {
    when (e) {
        is MyException.InvalidInput -> println("Invalid: ${e.message}")
        is MyException.NotFound -> println("Not found: ${e.id}")
        is MyException.Timeout -> println("Timeout!")
    }
}
```

---

## Async Functions

Mark functions as async with the `[Async]` attribute:

```udl
namespace template {
    [Throws=MyError, Async]
    string fetch_data(string url);
}
```

### Rust Implementation

Requires `tokio`:

```rust
pub async fn fetch_data(url: String) -> Result<String, MyError> {
    // Simulate async work
    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
    Ok(format!("Data from {}", url))
}
```

### Swift Usage

```swift
Task {
    do {
        let data = try await fetchData(url: "https://example.com")
        print(data)
    } catch {
        print("Error: \(error)")
    }
}
```

### Kotlin Usage

```kotlin
GlobalScope.launch {
    try {
        val data = fetchData("https://example.com")
        println(data)
    } catch (e: MyException) {
        println("Error: $e")
    }
}
```

---

## Objects and Interfaces

### Interface (Stateful Object)

```udl
interface Counter {
    constructor(u32 initial_value);

    void increment();
    void decrement();
    u32 value();
};
```

### Rust Implementation

```rust
#[derive(Debug)]
pub struct Counter {
    value: u32,
}

impl Counter {
    pub fn new(initial_value: u32) -> Self {
        Self {
            value: initial_value,
        }
    }

    pub fn increment(&mut self) {
        self.value += 1;
    }

    pub fn decrement(&mut self) {
        if self.value > 0 {
            self.value -= 1;
        }
    }

    pub fn value(&self) -> u32 {
        self.value
    }
}
```

### Swift Usage

```swift
let counter = Counter(initialValue: 10)
counter.increment()
counter.increment()
print(counter.value())  // 12
```

### Kotlin Usage

```kotlin
val counter = Counter(10u)
counter.increment()
counter.increment()
println(counter.value())  // 12
```

---

## Complete Example

Here's a complete example from this project (`src/template.udl`):

```udl
namespace template {
    // Simple functions
    
    double random();

    // Function with rich return type and error handling
    [Throws=TemplateError]
    EchoResult? echo(string input);

    // Async function with cancellation
    [Throws=TemplateError, Async]
};

// Configuration object
interface TemplateConfig {
    constructor(u64 max_input_size, boolean enable_validation);
    u64 max_input_size();
    boolean enable_validation();
    [Throws=TemplateError]
    EchoResult? validate_and_echo(string input);
};

// Cancellation token
interface CancellationToken {
    constructor();
    void cancel();
    boolean is_cancelled();
};

// Rich return type
dictionary EchoResult {
    string text;
    u32 length;
    u64 timestamp;
    string? hash;
};

// Error types
[Error]
interface TemplateError {
    InputTooLarge(u64 size, u64 max, string hash);
    InvalidInput(string message, string? input_preview);
    OperationCancelled(string operation);
};
```

---

## Best Practices

### 1. Keep UDL Synced with Rust

Always ensure your UDL definitions match your Rust function signatures exactly.

### 2. Use Clear Names

```udl
// Good
string get_user_name(u64 user_id);

// Bad
string gun(u64 u);
```

### 3. Document Complex Types

```udl
// User profile information
dictionary UserProfile {
    string name;
    string email;
    u32 age;
};
```

### 4. Group Related Functions

```udl
namespace template {
    // User management
    UserProfile create_user(string name);
    void delete_user(u64 id);

    // Data operations
    string process_data(string input);
    u64 get_data_size();
}
```

### 5. Use Meaningful Error Variants

```udl
[Error]
interface ApiError {
    NetworkError(string message);
    InvalidCredentials();
    RateLimitExceeded(u32 retry_after_seconds);
};
```

---

## Troubleshooting

### Build Error: "parse error"

**Problem**: UDL syntax error

**Solution**: Check for:
- Missing semicolons
- Mismatched braces
- Invalid type names
- Run `cargo build` to see detailed error

### Build Error: "mismatched types"

**Problem**: Rust implementation doesn't match UDL

**Solution**:
- Ensure function signatures match exactly
- Check return types (UDL `string` = Rust `String`, not `&str`)
- For interfaces, constructors should return `Self`, not `Arc<Self>`

### Functions Not Appearing in Swift/Kotlin

**Problem**: UDL not being processed

**Solution**:
1. Check `build.rs` calls `uniffi::generate_scaffolding("src/template.udl")`
2. Check `src/lib.rs` has `uniffi::include_scaffolding!("template")`
3. Rebuild: `cargo clean && cargo build`

### Type Conversion Errors

**Problem**: Wrong type in UDL

**Solution**: Use this mapping:
- UDL `string` → Rust `String` (not `&str`)
- UDL `u32` → Rust `u32` (exact match)
- UDL `boolean` → Rust `bool`

---

## Further Reading

- [UniFFI Official Documentation](https://mozilla.github.io/uniffi-rs/)
- [UniFFI UDL Reference](https://mozilla.github.io/uniffi-rs/udl/)
- [UniFFI Examples](https://github.com/mozilla/uniffi-rs/tree/main/examples)

---

## Quick Reference Card

```udl
// Basic function
ReturnType function_name(Type param);

// Optional return
Type? optional_function();

// Error handling
[Throws=ErrorType]
Type fallible_function();

// Async
[Async]
Type async_function();

// Async with error
[Throws=ErrorType, Async]
Type async_fallible();

// Dictionary (struct)
dictionary MyStruct {
    Type field;
    Type? optional_field;
};

// Enum
enum MyEnum {
    "Variant1",
    "Variant2",
};

// Interface (object)
interface MyObject {
    constructor(Type param);
    Type method();
};

// Error
[Error]
interface MyError {
    ErrorVariant1(Type data);
    ErrorVariant2();
};
```

---

*Last updated: 2025-01-11*
