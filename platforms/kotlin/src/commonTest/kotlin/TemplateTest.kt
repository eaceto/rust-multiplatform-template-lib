import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertTrue
import uniffi.rust_multiplatform_template_lib.*

class TemplateTest {
    @Test
    fun testHelloWorld() {
        val result = helloWorld()
        assertTrue(result)
    }

    @Test
    fun testEchoWithValue() {
        val result = echo("Hello, Kotlin!")
        assertEquals("Hello, Kotlin!", result)
    }

    @Test
    fun testEchoWithEmpty() {
        val result = echo("")
        assertNull(result)
    }

    @Test
    fun testRandom() {
        repeat(100) {
            val value = random()
            assertTrue(value >= 0.0 && value < 1.0)
        }
    }

    @Test
    fun testEchoWithLargeInput() {
        // Create a string larger than 1MB
        val largeString = "a".repeat(1_000_001)

        val exception = assertFailsWith<UniffiTemplateException.InputTooLarge> {
            echo(largeString)
        }
        assertEquals(1_000_001UL, exception.size)
        assertEquals(1_000_000UL, exception.max)
    }

    @Test
    fun testEchoAtMaxSize() {
        // Create a string exactly at 1MB
        val maxString = "a".repeat(1_000_000)
        val result = echo(maxString)
        assertEquals(maxString, result)
    }
}
