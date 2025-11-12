// TemplateExtensions.kt
// Organized extensions and convenience methods for the Rust Multiplatform Template Library
//
// This file provides a well-organized interface on top of the auto-generated UniFFI bindings.
// The auto-generated template.kt file should not be modified directly as it will be regenerated.

package com.rust.template.extensions

import uniffi.Template.*
import kotlinx.coroutines.*
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds

// ============================
// Public API - Global Functions
// ============================

/**
 * Echoes the input string with optional cancellation (async/suspend).
 *
 * Returns the input string wrapped in an [EchoResult] with additional metadata
 * including length, timestamp, and hash. Returns `null` for empty input.
 *
 * @param input The string to echo (max 1MB)
 * @param token Optional cancellation token to cancel the operation
 * @return [EchoResult] with metadata, or `null` if input is empty
 * @throws TemplateException.InputTooLarge if input exceeds 1MB
 * @throws TemplateException.InvalidInput if input contains invalid characters
 * @throws TemplateException.OperationCancelled if cancelled via token
 */
@Throws(TemplateException::class)
suspend fun templateEcho(
    input: String,
    token: CancellationToken? = null
): EchoResult? = echo(input, token)

/**
 * Generates a random number between 0.0 and 1.0 (async/suspend).
 *
 * Uses a cryptographically secure random number generator.
 *
 * @return Random floating point value in range [0.0, 1.0)
 */
suspend fun templateRandom(): Double = random()

// ============================
// EchoResult Extensions
// ============================

/**
 * Human-readable description of the result.
 */
val EchoResult.description: String
    get() = "EchoResult(text=\"$text\", length=$length, timestamp=$timestamp)"

/**
 * Formatted timestamp as a readable string.
 */
val EchoResult.formattedTimestamp: String
    get() = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.US)
        .format(java.util.Date(timestamp.toLong() * 1000))

/**
 * Pretty-printed hash value.
 */
val EchoResult.formattedHash: String?
    get() = hash?.let { "0x$it" }

/**
 * Check if the result has a hash.
 */
val EchoResult.hasHash: Boolean
    get() = hash != null

// ============================
// TemplateException Extensions
// ============================

/**
 * Human-readable detailed description of the error.
 */
val TemplateException.detailedDescription: String
    get() = when (this) {
        is TemplateException.InputTooLarge ->
            "Input size ($size bytes) exceeds maximum allowed size ($max bytes). Hash: $hash"
        is TemplateException.InvalidInput -> {
            inputPreview?.let { preview ->
                "Invalid input: $errorMessage. Preview: \"${preview.take(50)}...\""
            } ?: "Invalid input: $errorMessage"
        }
        is TemplateException.OperationCancelled ->
            "Operation '$operation' was cancelled"
    }

/**
 * Short error code for logging.
 */
val TemplateException.errorCode: String
    get() = when (this) {
        is TemplateException.InputTooLarge -> "INPUT_TOO_LARGE"
        is TemplateException.InvalidInput -> "INVALID_INPUT"
        is TemplateException.OperationCancelled -> "OPERATION_CANCELLED"
    }

/**
 * Whether the error is recoverable (user can retry with different input).
 */
val TemplateException.isRecoverable: Boolean
    get() = when (this) {
        is TemplateException.InputTooLarge,
        is TemplateException.InvalidInput -> true
        is TemplateException.OperationCancelled -> false
    }

// ============================
// CancellationToken Extensions
// ============================

/**
 * Creates a cancellation token that automatically cancels after a timeout.
 *
 * @param timeout Time duration before cancellation
 * @return A new cancellation token that will cancel after the timeout
 */
fun CancellationToken.Companion.withTimeout(timeout: Duration): CancellationToken {
    val token = CancellationToken()
    kotlinx.coroutines.GlobalScope.launch {
        delay(timeout)
        token.cancel()
    }
    return token
}

/**
 * Creates a cancellation token that automatically cancels after a timeout in seconds.
 *
 * @param seconds Timeout in seconds
 * @return A new cancellation token that will cancel after the timeout
 */
fun CancellationToken.Companion.withTimeoutSeconds(seconds: Long): CancellationToken =
    withTimeout(seconds.seconds)

/**
 * Checks if the token is active (not cancelled).
 */
val CancellationToken.isActive: Boolean
    get() = !isCancelled()

// ============================
// TemplateConfig Extensions
// ============================

/**
 * Creates a default configuration.
 */
fun TemplateConfig.Companion.default(): TemplateConfig =
    TemplateConfig(maxInputSize = 1_000_000u, enableValidation = true)

/**
 * Creates a configuration with validation disabled (for trusted input).
 */
fun TemplateConfig.Companion.noValidation(): TemplateConfig =
    TemplateConfig(maxInputSize = 1_000_000u, enableValidation = false)

/**
 * Creates a configuration with custom size limit.
 *
 * @param maxSize Maximum input size in bytes
 * @return Configuration with specified max size and validation enabled
 */
fun TemplateConfig.Companion.withMaxSize(maxSize: ULong): TemplateConfig =
    TemplateConfig(maxInputSize = maxSize, enableValidation = true)

/**
 * Validates input without echoing.
 *
 * @param input The string to validate
 * @throws TemplateException if validation fails
 */
@Throws(TemplateException::class)
fun TemplateConfig.validate(input: String) {
    if (enableValidation()) {
        val size = input.toByteArray(Charsets.UTF_8).size.toULong()
        if (size > maxInputSize()) {
            throw TemplateException.InputTooLarge(
                size = size,
                max = maxInputSize(),
                hash = input.hashCode().toString(16)
            )
        }
    }
}

// ============================
// Result Type Alias
// ============================

/**
 * Result type for template operations.
 */
typealias TemplateResult<T> = Result<T>

// ============================
// Helper Functions
// ============================

/**
 * Safely executes a template operation and returns a [Result].
 *
 * @param operation The operation to execute
 * @return Result containing either the value or the exception
 */
inline fun <T> safeTemplateOperation(operation: () -> T): Result<T> =
    runCatching(operation)

/**
 * Safely executes an async template operation and returns a [Result].
 *
 * @param operation The async operation to execute
 * @return Result containing either the value or the exception
 */
suspend inline fun <T> safeTemplateOperationAsync(
    crossinline operation: suspend () -> T
): Result<T> = runCatching {
    operation()
}

/**
 * Executes a template operation with a timeout.
 *
 * @param timeout Maximum time to wait
 * @param operation The operation to execute
 * @return The result of the operation
 * @throws kotlinx.coroutines.TimeoutCancellationException if timeout is exceeded
 */
suspend inline fun <T> withTemplateTimeout(
    timeout: Duration,
    crossinline operation: suspend () -> T
): T = withTimeout(timeout) {
    operation()
}

/**
 * Retries a template operation up to [maxAttempts] times.
 *
 * @param maxAttempts Maximum number of attempts (default 3)
 * @param delayBetweenAttempts Delay between retry attempts (default 100ms)
 * @param operation The operation to execute
 * @return The result of the operation
 * @throws TemplateException if all attempts fail
 */
suspend inline fun <T> retryTemplateOperation(
    maxAttempts: Int = 3,
    delayBetweenAttempts: Duration = Duration.ZERO,
    crossinline operation: suspend () -> T
): T {
    var lastException: Exception? = null
    
    repeat(maxAttempts) { attempt ->
        try {
            return operation()
        } catch (e: TemplateException) {
            lastException = e
            if (!e.isRecoverable) {
                throw e
            }
            if (attempt < maxAttempts - 1) {
                delay(delayBetweenAttempts)
            }
        }
    }
    
    throw lastException ?: IllegalStateException("Retry failed with no exception")
}

// ============================
// DSL Builders
// ============================

/**
 * Builds a [TemplateConfig] using a DSL.
 *
 * Example:
 * ```
 * val config = templateConfig {
 *     maxInputSize = 5000u
 *     enableValidation = true
 * }
 * ```
 */
inline fun templateConfig(block: TemplateConfigBuilder.() -> Unit): TemplateConfig =
    TemplateConfigBuilder().apply(block).build()

/**
 * Builder for [TemplateConfig].
 */
class TemplateConfigBuilder {
    var maxInputSize: ULong = 1_000_000u
    var enableValidation: Boolean = true
    
    fun build(): TemplateConfig = TemplateConfig(
        maxInputSize = maxInputSize,
        enableValidation = enableValidation
    )
}
