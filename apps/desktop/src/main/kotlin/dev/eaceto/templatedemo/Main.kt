package dev.eaceto.templatedemo

import uniffi.rust_multiplatform_template_lib.*

fun main() {
    printHeader()
    println()

    // Test: Backend Info (LLM)
    testBackendInfo()
    println()

    printFooter()
}

fun printHeader() {
    println("=" .repeat(60))
    println("Rust LLM Library - Desktop CLI Demo")
    println("=" .repeat(60))
    println("Powered by HuggingFace Candle")
}

fun printFooter() {
    println("=" .repeat(60))
    println("Demo completed!")
    println("=" .repeat(60))
}

fun testBackendInfo() {
    println("-" .repeat(60))
    println("[TEST] Backend Info (LLM - Candle)")
    println("-" .repeat(60))
    println("Description: Detects available compute backends for LLM inference")
    println()

    try {
        print("Calling getBackendInfo()... ")
        val result = getBackendInfo()
        println("[SUCCESS]")
        println("Backend Information:")
        println("  $result")
        println()

        // Parse and display components
        if (result.contains("Candle backend")) {
            println("  ✓ Candle library detected")
        }
        if (result.contains("Metal")) {
            println("  ✓ Metal backend available (Apple GPU acceleration)")
        }
        if (result.contains("CPU")) {
            println("  ✓ CPU backend available")
        }
        if (result.contains("threads")) {
            val threadsMatch = Regex("""(\d+)""").find(result)
            threadsMatch?.let {
                println("  ✓ Available CPU threads: ${it.value}")
            }
        }
    } catch (e: Exception) {
        println("[FAILED]")
        println("Error: ${e.message}")
        e.printStackTrace()
    }
}
