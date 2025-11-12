package dev.eaceto.templatedemo

import kotlinx.coroutines.runBlocking
import uniffi.Template.*

fun main() = runBlocking {
    printHeader()
    println()

    // Test 1: Echo
    testEcho()
    println()

    // Test 2: Random
    testRandom()
    println()

    printFooter()
}

fun printHeader() {
    println("=" .repeat(60))
    println("Rust Multiplatform Template - Desktop CLI Demo")
    println("=" .repeat(60))
    println("Testing Rust functions via UniFFI from JVM")
}

fun printFooter() {
    println("=" .repeat(60))
    println("All tests completed!")
    println("=" .repeat(60))
}

suspend fun testEcho() {
    println("-" .repeat(60))
    println("[TEST 1/2] Echo")
    println("-" .repeat(60))
    println("Description: Returns the input string with metadata, or null if empty")
    println()

    val testInputs = listOf(
        "Hello from Kotlin/JVM!",
        "Testing UniFFI",
        "",
        "Rust is awesome"
    )

    testInputs.forEachIndexed { index, input ->
        try {
            val displayInput = if (input.isEmpty()) "(empty string)" else "\"$input\""
            print("  [${index + 1}/${testInputs.size}] Calling echo($displayInput)... ")

            val result = echo(input, null)

            if (result != null) {
                println("[SUCCESS]")
                println("      Text: \"${result.text}\"")
                println("      Length: ${result.length}")
                println("      Timestamp: ${result.timestamp}")
            } else {
                println("[SUCCESS]")
                println("      Result: null (as expected for empty input)")
            }
        } catch (e: Exception) {
            println("[FAILED]")
            println("      Error: ${e.message}")
        }
        println()
    }
}

suspend fun testRandom() {
    println("-" .repeat(60))
    println("[TEST 2/2] Random Number Generator")
    println("-" .repeat(60))
    println("Description: Generates random numbers between 0.0 and 1.0")
    println()

    val numTests = 5
    val results = mutableListOf<Double>()

    println("  Generating $numTests random numbers:")
    println()

    repeat(numTests) { index ->
        try {
            print("  [${index + 1}/$numTests] Calling random()... ")
            val result = random()
            results.add(result)
            println("[SUCCESS]")
            println("      Result: ${"%.8f".format(result)}")
        } catch (e: Exception) {
            println("[FAILED]")
            println("      Error: ${e.message}")
        }
    }

    if (results.isNotEmpty()) {
        println()
        println("  Statistics:")
        println("    Min:     ${"%.8f".format(results.minOrNull())}")
        println("    Max:     ${"%.8f".format(results.maxOrNull())}")
        println("    Average: ${"%.8f".format(results.average())}")

        // Verify all results are in valid range
        val allInRange = results.all { it in 0.0..1.0 }
        println("    All values in range [0.0, 1.0]: $allInRange")
    }
}
