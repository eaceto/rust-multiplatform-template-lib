# Kotlin Usage Examples

This document shows how to use the Rust template library in Kotlin/Android applications with all the new async-only improvements.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Error Handling](#error-handling)
- [Coroutines and Suspend Functions](#coroutines-and-suspend-functions)
- [Cancellation](#cancellation)
- [Configuration Objects](#configuration-objects)
- [Complete Example App](#complete-example-app)

---

## Basic Usage

### Echo with Rich Return Type

```kotlin
import uniffi.rust_multiplatform_template_lib.*

suspend fun echoExample() {
    try {
        val echoResult = echo("Hello, Kotlin!", null)

        if (echoResult != null) {
            println("Text: ${echoResult.text}")
            println("Length: ${echoResult.length}")
            println("Timestamp: ${echoResult.timestamp}")

            echoResult.hash?.let { hash ->
                println("Hash: $hash")
            }
        } else {
            println("Empty input returned null")
        }
    } catch (e: TemplateException) {
        println("Error: $e")
    }
}
```

### Random Number Generation

```kotlin
suspend fun randomExample() {
    val randomValue = random()
    println("Random: $randomValue")  // 0.0 to 1.0
}
```

---

## Error Handling

### Structured Error Handling

The new error system provides structured error information instead of just strings:

```kotlin
import uniffi.rust_multiplatform_template_lib.*
import android.widget.Toast

suspend fun processInput(input: String, context: Context) {
    try {
        val result = echo(input, null)
        println("Success: ${result?.text ?: "null"}")
    } catch (e: TemplateException) {
        when (e) {
            is TemplateException.InputTooLarge -> {
                println("Input too large!")
                println("  Size: ${e.size} bytes")
                println("  Maximum allowed: ${e.max} bytes")
                println("  Hash (for debugging): ${e.hash}")

                // Show user-friendly message
                val sizeStr = android.text.format.Formatter.formatFileSize(context, e.size.toLong())
                val maxStr = android.text.format.Formatter.formatFileSize(context, e.max.toLong())

                Toast.makeText(
                    context,
                    "Input too large: $sizeStr exceeds maximum of $maxStr",
                    Toast.LENGTH_LONG
                ).show()
            }

            is TemplateException.InvalidInput -> {
                println("Invalid input: ${e.message}")
                e.inputPreview?.let { preview ->
                    println("  Preview: $preview")
                }

                Toast.makeText(
                    context,
                    "Invalid input: ${e.message}",
                    Toast.LENGTH_SHORT
                ).show()
            }

            is TemplateException.OperationCancelled -> {
                println("Operation cancelled: ${e.operation}")

                Toast.makeText(
                    context,
                    "Operation was cancelled",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }
}
```

### Practical Error Handling in Activity

```kotlin
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch
import uniffi.rust_multiplatform_template_lib.*
import java.text.SimpleDateFormat
import java.util.*

class InputActivity : AppCompatActivity() {
    private lateinit var inputField: EditText
    private lateinit var resultView: TextView
    private lateinit var processButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_input)

        inputField = findViewById(R.id.inputField)
        resultView = findViewById(R.id.resultView)
        processButton = findViewById(R.id.processButton)

        processButton.setOnClickListener {
            val input = inputField.text.toString()
            if (input.isEmpty()) {
                resultView.text = "Please enter some text"
                return@setOnClickListener
            }

            lifecycleScope.launch {
                processInputAsync(input)
            }
        }
    }

    private suspend fun processInputAsync(input: String) {
        try {
            val result = echo(input, null)

            if (result != null) {
                val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US)
                val date = Date(result.timestamp.toLong() * 1000)

                resultView.text = """
                    Result: ${result.text}
                    Length: ${result.length} characters
                    Time: ${dateFormat.format(date)}
                """.trimIndent()
            }
        } catch (e: TemplateException) {
            handleTemplateError(e)
        }
    }

    private fun handleTemplateError(error: TemplateException) {
        when (error) {
            is TemplateException.InputTooLarge -> {
                val sizeStr = android.text.format.Formatter.formatFileSize(this, error.size.toLong())
                val maxStr = android.text.format.Formatter.formatFileSize(this, error.max.toLong())

                resultView.text = """
                    ❌ Input too large
                    Your input: $sizeStr
                    Maximum: $maxStr
                """.trimIndent()
            }

            is TemplateException.InvalidInput -> {
                var text = "❌ Invalid input: ${error.message}"
                error.inputPreview?.let { preview ->
                    text += "\nPreview: $preview"
                }
                resultView.text = text
            }

            is TemplateException.OperationCancelled -> {
                resultView.text = "⚠️ ${error.operation} was cancelled"
            }
        }
    }
}
```

---

## Coroutines and Suspend Functions

### Basic Async Echo

All functions in the library are now suspend functions and must be called from a coroutine context:

```kotlin
import kotlinx.coroutines.runBlocking
import uniffi.rust_multiplatform_template_lib.*

fun asyncExample() = runBlocking {
    try {
        val result = echo("Async hello!", null)

        result?.let {
            println("Async result: ${it.text}")
            println("Completed at: ${it.timestamp}")
        }
    } catch (e: TemplateException) {
        when (e) {
            is TemplateException.OperationCancelled ->
                println("Cancelled: ${e.operation}")
            is TemplateException.InputTooLarge ->
                println("Too large: ${e.size} > ${e.max}")
            is TemplateException.InvalidInput ->
                println("Invalid: ${e.message}")
        }
    }
}
```

### Using with Jetpack Compose

```kotlin
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import uniffi.rust_multiplatform_template_lib.*
import java.text.SimpleDateFormat
import java.util.*

@Composable
fun AsyncEchoScreen() {
    var input by remember { mutableStateOf("") }
    var result by remember { mutableStateOf<EchoResult?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<TemplateException?>(null) }

    val scope = rememberCoroutineScope()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        OutlinedTextField(
            value = input,
            onValueChange = { input = it },
            label = { Text("Enter text") },
            modifier = Modifier.fillMaxWidth()
        )

        Button(
            onClick = {
                scope.launch {
                    processAsync(
                        input = input,
                        onLoading = { isLoading = it },
                        onResult = { result = it },
                        onError = { error = it }
                    )
                }
            },
            enabled = !isLoading,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Process Async")
        }

        if (isLoading) {
            CircularProgressIndicator()
        }

        result?.let { echoResult ->
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US)
            val date = Date(echoResult.timestamp.toLong() * 1000)

            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Result: ${echoResult.text}")
                    Text("Length: ${echoResult.length}")
                    Text("Time: ${dateFormat.format(date)}")
                }
            }
        }

        error?.let { templateError ->
            ErrorCard(error = templateError)
        }
    }
}

@Composable
fun ErrorCard(error: TemplateException) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.errorContainer
        )
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            when (error) {
                is TemplateException.InputTooLarge -> {
                    Text("❌ Input Too Large", style = MaterialTheme.typography.titleMedium)
                    Text("Size: ${android.text.format.Formatter.formatFileSize(null, error.size.toLong())}")
                    Text("Max: ${android.text.format.Formatter.formatFileSize(null, error.max.toLong())}")
                }

                is TemplateException.InvalidInput -> {
                    Text("❌ Invalid Input", style = MaterialTheme.typography.titleMedium)
                    Text(error.message)
                    error.inputPreview?.let { preview ->
                        Text("Preview: $preview", style = MaterialTheme.typography.bodySmall)
                    }
                }

                is TemplateException.OperationCancelled -> {
                    Text("⚠️ Cancelled", style = MaterialTheme.typography.titleMedium)
                    Text("Operation: ${error.operation}")
                }
            }
        }
    }
}

suspend fun processAsync(
    input: String,
    onLoading: (Boolean) -> Unit,
    onResult: (EchoResult?) -> Unit,
    onError: (TemplateException?) -> Unit
) {
    onLoading(true)
    onError(null)
    onResult(null)

    try {
        val result = echo(input, null)
        onResult(result)
    } catch (e: TemplateException) {
        onError(e)
    }

    onLoading(false)
}
```

---

## Cancellation

### Basic Cancellation

```kotlin
import kotlinx.coroutines.*
import uniffi.rust_multiplatform_template_lib.*

fun cancellableOperation() = runBlocking {
    val cancellationToken = CancellationToken()

    // Start async operation
    val job = launch {
        try {
            val result = echo(
                input = "Long running operation",
                token = cancellationToken
            )
            println("Completed: ${result?.text ?: "null"}")
        } catch (e: TemplateException.OperationCancelled) {
            println("Successfully cancelled: ${e.operation}")
        }
    }

    // Cancel after 1 second
    launch {
        delay(1000)
        cancellationToken.cancel()
    }

    job.join()
}
```

### Cancellation with Jetpack Compose

```kotlin
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import uniffi.rust_multiplatform_template_lib.*

@Composable
fun CancellableScreen() {
    var input by remember { mutableStateOf("") }
    var result by remember { mutableStateOf<EchoResult?>(null) }
    var isProcessing by remember { mutableStateOf(false) }
    var cancellationToken by remember { mutableStateOf<CancellationToken?>(null) }
    var error by remember { mutableStateOf<String?>(null) }

    val scope = rememberCoroutineScope()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        OutlinedTextField(
            value = input,
            onValueChange = { input = it },
            label = { Text("Enter text") },
            modifier = Modifier.fillMaxWidth()
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Button(
                onClick = {
                    scope.launch {
                        startProcessing(
                            input = input,
                            onProcessing = { isProcessing = it },
                            onToken = { cancellationToken = it },
                            onResult = { result = it },
                            onError = { error = it }
                        )
                    }
                },
                enabled = !isProcessing,
                modifier = Modifier.weight(1f)
            ) {
                Text("Start")
            }

            Button(
                onClick = { cancellationToken?.cancel() },
                enabled = isProcessing,
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.error
                ),
                modifier = Modifier.weight(1f)
            ) {
                Text("Cancel")
            }
        }

        if (isProcessing) {
            LinearProgressIndicator(modifier = Modifier.fillMaxWidth())
            Text("Processing...")
        }

        result?.let { echoResult ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            ) {
                Text(
                    text = "Result: ${echoResult.text}",
                    modifier = Modifier.padding(16.dp)
                )
            }
        }

        error?.let { errorMsg ->
            Text(
                text = errorMsg,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(16.dp)
            )
        }
    }
}

suspend fun startProcessing(
    input: String,
    onProcessing: (Boolean) -> Unit,
    onToken: (CancellationToken?) -> Unit,
    onResult: (EchoResult?) -> Unit,
    onError: (String?) -> Unit
) {
    onProcessing(true)
    onError(null)
    onResult(null)

    // Create new cancellation token
    val token = CancellationToken()
    onToken(token)

    try {
        val processResult = echo(input, token)
        onResult(processResult)
    } catch (e: TemplateException) {
        when (e) {
            is TemplateException.OperationCancelled ->
                onError("Operation was cancelled")
            else ->
                onError("Error: ${e.message}")
        }
    }

    onProcessing(false)
    onToken(null)
}
```

### Using Kotlin Coroutine Cancellation with CancellationToken

```kotlin
import kotlinx.coroutines.*
import uniffi.rust_multiplatform_template_lib.*

suspend fun cancellableWithTimeout() = coroutineScope {
    val cancellationToken = CancellationToken()

    // Link Kotlin coroutine cancellation with the native token
    val job = launch {
        try {
            val result = echo("Long operation", cancellationToken)
            println("Success: ${result?.text}")
        } catch (e: TemplateException.OperationCancelled) {
            println("Native cancellation detected")
        } catch (e: CancellationException) {
            println("Kotlin coroutine cancelled")
            cancellationToken.cancel() // Cancel native operation too
            throw e
        }
    }

    // Cancel after timeout
    withTimeoutOrNull(2000) {
        job.join()
    } ?: run {
        println("Timeout - cancelling")
        cancellationToken.cancel()
        job.cancelAndJoin()
    }
}
```

---

## Configuration Objects

### Using TemplateConfig

```kotlin
import uniffi.rust_multiplatform_template_lib.*

suspend fun configExample() {
    // Create configuration with custom settings
    val config = TemplateConfig(
        maxInputSize = 1000u,  // 1KB limit
        enableValidation = true
    )

    println("Max size: ${config.maxInputSize()}")
    println("Validation: ${config.enableValidation()}")

    // Use the config
    try {
        val result = config.validateAndEcho("test", null)
        result?.let {
            println("Validated: ${it.text}")
        }
    } catch (e: TemplateException) {
        println("Validation failed: $e")
    }
}
```

### Configuration Manager Pattern

```kotlin
import uniffi.rust_multiplatform_template_lib.*

class TemplateManager {
    private val standardConfig: TemplateConfig = TemplateConfig(
        maxInputSize = 1_000_000u,  // 1MB
        enableValidation = true
    )

    private val strictConfig: TemplateConfig = TemplateConfig(
        maxInputSize = 10_000u,  // 10KB
        enableValidation = true
    )

    suspend fun processWithStandardConfig(input: String): EchoResult? {
        return standardConfig.validateAndEcho(input, null)
    }

    suspend fun processWithStrictConfig(input: String): EchoResult? {
        return strictConfig.validateAndEcho(input, null)
    }

    suspend fun validateInput(input: String, strict: Boolean = false): Boolean {
        return try {
            val config = if (strict) strictConfig else standardConfig
            config.validateAndEcho(input, null)
            true
        } catch (e: TemplateException) {
            false
        }
    }
}

// Usage
suspend fun managerExample() {
    val manager = TemplateManager()

    try {
        val result = manager.processWithStandardConfig("Hello")
        println("Processed: ${result?.text ?: "null"}")
    } catch (e: TemplateException) {
        when (e) {
            is TemplateException.InputTooLarge ->
                println("Input ${e.size} exceeds limit ${e.max}")
            is TemplateException.InvalidInput ->
                println("Invalid: ${e.message}")
            is TemplateException.OperationCancelled ->
                println("Cancelled")
        }
    }
}
```

### DSL Builder Pattern

```kotlin
import com.rust.template.extensions.*

suspend fun dslExample() {
    // Using the DSL builder from TemplateExtensions.kt
    val config = templateConfig {
        maxInputSize = 5000u
        enableValidation = true
    }

    try {
        val result = config.validateAndEcho("Hello from DSL", null)
        println("Result: ${result?.text}")
    } catch (e: TemplateException) {
        println("Error: ${e.detailedDescription}")
        println("Error code: ${e.errorCode}")
        println("Recoverable: ${e.isRecoverable}")
    }
}
```

---

## Complete Example App

Here's a complete Android app showcasing all features:

### ViewModel

```kotlin
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import uniffi.rust_multiplatform_template_lib.*

data class AppState(
    val input: String = "",
    val result: String? = null,
    val error: String? = null,
    val isProcessing: Boolean = false
)

class TemplateViewModel : ViewModel() {
    private val _state = MutableStateFlow(AppState())
    val state: StateFlow<AppState> = _state

    private var cancellationToken: CancellationToken? = null
    private val config = TemplateConfig(
        maxInputSize = 1_000_000u,
        enableValidation = true
    )

    fun updateInput(input: String) {
        _state.value = _state.value.copy(input = input)
    }

    fun testRandom() {
        viewModelScope.launch {
            try {
                val value = random()
                _state.value = _state.value.copy(
                    result = "Random: %.6f".format(value),
                    error = null
                )
            } catch (e: Exception) {
                _state.value = _state.value.copy(
                    error = "Error: ${e.message}",
                    result = null
                )
            }
        }
    }

    fun echoAsync() {
        viewModelScope.launch {
            try {
                val result = echo(_state.value.input, null)

                if (result != null) {
                    _state.value = _state.value.copy(
                        result = """
                            Text: ${result.text}
                            Length: ${result.length}
                            Timestamp: ${result.timestamp}
                        """.trimIndent(),
                        error = null
                    )
                } else {
                    _state.value = _state.value.copy(
                        result = "Empty input",
                        error = null
                    )
                }
            } catch (e: TemplateException) {
                _state.value = _state.value.copy(
                    error = formatError(e),
                    result = null
                )
            }
        }
    }

    fun startLongOperation() {
        viewModelScope.launch {
            _state.value = _state.value.copy(
                isProcessing = true,
                error = null,
                result = null
            )

            cancellationToken = CancellationToken()

            try {
                val result = echo(
                    "Long operation: ${_state.value.input}",
                    cancellationToken
                )

                result?.let {
                    _state.value = _state.value.copy(
                        result = "Completed: ${it.text}",
                        isProcessing = false
                    )
                }
            } catch (e: TemplateException) {
                _state.value = _state.value.copy(
                    error = formatError(e),
                    isProcessing = false
                )
            } finally {
                cancellationToken = null
            }
        }
    }

    fun cancelOperation() {
        cancellationToken?.cancel()
    }

    private fun formatError(error: TemplateException): String {
        return when (error) {
            is TemplateException.InputTooLarge -> {
                val sizeStr = android.text.format.Formatter.formatFileSize(null, error.size.toLong())
                val maxStr = android.text.format.Formatter.formatFileSize(null, error.max.toLong())
                """
                    Input too large:
                    Size: $sizeStr
                    Max: $maxStr
                    Hash: ${error.hash}
                """.trimIndent()
            }

            is TemplateException.InvalidInput -> {
                var text = "Invalid input: ${error.message}"
                error.inputPreview?.let { preview ->
                    text += "\nPreview: $preview"
                }
                text
            }

            is TemplateException.OperationCancelled ->
                "Cancelled: ${error.operation}"
        }
    }
}
```

### Compose UI

```kotlin
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TemplateApp() {
    val viewModel: TemplateViewModel = viewModel()
    val state by viewModel.state.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Template Library") })
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Basic Operations Section
            Text("Basic Operations", style = MaterialTheme.typography.titleLarge)

            Button(
                onClick = { viewModel.testRandom() },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Random")
            }

            Divider()

            // Echo Section
            Text("Echo", style = MaterialTheme.typography.titleLarge)

            OutlinedTextField(
                value = state.input,
                onValueChange = { viewModel.updateInput(it) },
                label = { Text("Input") },
                modifier = Modifier.fillMaxWidth()
            )

            Button(
                onClick = { viewModel.echoAsync() },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Echo Async")
            }

            Divider()

            // Async with Cancellation Section
            Text("Async with Cancellation", style = MaterialTheme.typography.titleLarge)

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = { viewModel.startLongOperation() },
                    enabled = !state.isProcessing,
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Start Long Operation")
                }

                Button(
                    onClick = { viewModel.cancelOperation() },
                    enabled = state.isProcessing,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error
                    ),
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Cancel")
                }
            }

            if (state.isProcessing) {
                LinearProgressIndicator(modifier = Modifier.fillMaxWidth())
            }

            Divider()

            // Result Section
            Text("Result", style = MaterialTheme.typography.titleLarge)

            state.result?.let { result ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer
                    )
                ) {
                    Text(
                        text = result,
                        modifier = Modifier.padding(16.dp),
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                }
            }

            state.error?.let { error ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.errorContainer
                    )
                ) {
                    Text(
                        text = error,
                        modifier = Modifier.padding(16.dp),
                        color = MaterialTheme.colorScheme.onErrorContainer
                    )
                }
            }
        }
    }
}
```

---

## Best Practices

1. **Always use suspend functions** - All library functions are async and must be called from coroutine contexts
2. **Handle errors explicitly** - Don't just catch and ignore, provide meaningful feedback
3. **Use structured error matching** - Pattern match on error variants for better UX
4. **Cancel long operations** - Implement cancellation for better user experience
5. **Use configuration objects** - For reusable validation settings
6. **Link coroutine cancellation** - Connect Kotlin coroutine cancellation with native CancellationToken
7. **Use DSL builders** - For clean, idiomatic Kotlin configuration
8. **Collect StateFlow on main thread** - When updating UI in Compose or Activities
9. **Use viewModelScope** - For automatic cancellation when ViewModel is cleared
10. **Format file sizes properly** - Use Android's `Formatter.formatFileSize()` for user-friendly messages

---

## Extension Functions

The library provides rich Kotlin extensions in `TemplateExtensions.kt`:

### EchoResult Extensions

```kotlin
val result = echo("test", null)
result?.let {
    println(it.description)          // Human-readable description
    println(it.formattedTimestamp)   // Formatted date string
    println(it.formattedHash)        // Pretty-printed hash
    println(it.hasHash)              // Boolean check
}
```

### TemplateException Extensions

```kotlin
try {
    echo(largeInput, null)
} catch (e: TemplateException) {
    println(e.detailedDescription)  // Full error description
    println(e.errorCode)            // Error code for logging
    println(e.isRecoverable)        // Whether user can retry
}
```

### CancellationToken Extensions

```kotlin
// Auto-cancel after timeout
val token = CancellationToken.withTimeout(5.seconds)

// Check if active
if (token.isActive) {
    // Perform operation
}
```

### Helper Functions

```kotlin
// Safe operation with Result type
val result: Result<EchoResult?> = safeTemplateOperationAsync {
    echo("test", null)
}

// Operation with timeout
val result = withTemplateTimeout(3.seconds) {
    echo("long input", null)
}

// Retry with backoff
val result = retryTemplateOperation(
    maxAttempts = 3,
    delayBetweenAttempts = 100.milliseconds
) {
    echo("flaky operation", null)
}
```

---

*Last updated: 2025-01-11*
