// TemplateExtensions.swift
// Organized extensions and convenience methods for the Rust Multiplatform Template Library
//
// This file provides a well-organized interface on top of the auto-generated UniFFI bindings.
// The auto-generated template.swift file should not be modified directly as it will be regenerated.

import Foundation

// MARK: - Public API

// MARK: Global Functions

/// Echoes the input string with metadata (async with cancellation)
public func templateEcho(_ input: String, token: CancellationToken? = nil) async throws -> EchoResult? {
    return try await echo(input: input, token: token)
}

/// Generates a random number between 0.0 and 1.0 (async)
public func templateRandom() async -> Double {
    return await random()
}

// MARK: - EchoResult Extensions

extension EchoResult {
    /// Human-readable description of the result
    public var description: String {
        return "EchoResult(text: \"\(text)\", length: \(length), timestamp: \(timestamp))"
    }

    /// Formatted timestamp as Date
    public var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    /// Pretty-printed hash value
    public var formattedHash: String? {
        guard let hash = hash else { return nil }
        return "0x\(hash)"
    }
}

// MARK: - TemplateError Extensions

extension TemplateError {
    /// Human-readable detailed description
    public var detailedDescription: String {
        switch self {
        case .InputTooLarge(let size, let max, let hash):
            return "Input size (\(size) bytes) exceeds maximum allowed size (\(max) bytes). Hash: \(hash)"
        case .InvalidInput(let message, let preview):
            if let preview = preview {
                return "Invalid input: \(message). Preview: \"\(preview.prefix(50))...\""
            }
            return "Invalid input: \(message)"
        case .OperationCancelled(let operation):
            return "Operation '\(operation)' was cancelled"
        }
    }

    /// Short error code for logging
    public var errorCode: String {
        switch self {
        case .InputTooLarge:
            return "INPUT_TOO_LARGE"
        case .InvalidInput:
            return "INVALID_INPUT"
        case .OperationCancelled:
            return "OPERATION_CANCELLED"
        }
    }

    /// Whether the error is recoverable
    public var isRecoverable: Bool {
        switch self {
        case .InputTooLarge, .InvalidInput:
            return true
        case .OperationCancelled:
            return false
        }
    }
}

// MARK: - CancellationToken Extensions

extension CancellationToken {
    /// Creates a cancellation token that automatically cancels after a timeout
    public static func withTimeout(_ timeout: TimeInterval) -> CancellationToken {
        let token = CancellationToken()
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            token.cancel()
        }
        return token
    }

    /// Checks if the token is active (not cancelled)
    public var isActive: Bool {
        return !isCancelled()
    }
}

// MARK: - TemplateConfig Extensions

extension TemplateConfig {
    /// Creates a default configuration
    public static var `default`: TemplateConfig {
        return TemplateConfig(maxInputSize: 1_000_000, enableValidation: true)
    }

    /// Creates a configuration with validation disabled
    public static var noValidation: TemplateConfig {
        return TemplateConfig(maxInputSize: 1_000_000, enableValidation: false)
    }

    /// Creates a configuration with custom size limit
    public static func withMaxSize(_ maxSize: UInt64) -> TemplateConfig {
        return TemplateConfig(maxInputSize: maxSize, enableValidation: true)
    }

    /// Validates input without echoing (async)
    public func validate(_ input: String) throws {
        if enableValidation() {
            let size = UInt64(input.utf8.count)
            if size > maxInputSize() {
                throw TemplateError.InputTooLarge(
                    size: size,
                    max: maxInputSize(),
                    hash: String(input.hashValue, radix: 16)
                )
            }
        }
    }
}

// MARK: - Convenience Type Aliases

/// Result type for template operations
public typealias TemplateResult<T> = Result<T, TemplateError>

// MARK: - Helper Functions

/// Safely executes an async template operation and returns a Result
public func safeTemplateOperationAsync<T>(_ operation: @escaping () async throws -> T) async -> TemplateResult<T> {
    do {
        let result = try await operation()
        return .success(result)
    } catch let error as TemplateError {
        return .failure(error)
    } catch {
        return .failure(.InvalidInput(
            errorMessage: "Unexpected error: \(error.localizedDescription)",
            inputPreview: nil
        ))
    }
}
