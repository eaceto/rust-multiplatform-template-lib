import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.coroutines.test.runTest
import uniffi.Template.*
import com.rust.template.extensions.*

class TemplateTest {

    @Test
    fun testEchoWithValue() = runTest {
        val result = templateEcho("Hello, Kotlin!", null)
        assertTrue(result != null)
        assertEquals("Hello, Kotlin!", result?.text)
        assertEquals(14u, result?.length)
    }

    @Test
    fun testEchoWithEmpty() = runTest {
        val result = templateEcho("", null)
        assertNull(result)
    }

    @Test
    fun testRandom() = runTest {
        repeat(100) {
            val value = templateRandom()
            assertTrue(value >= 0.0 && value < 1.0)
        }
    }

    @Test
    fun testEchoWithLargeInput() = runTest {
        // Create a string larger than 1MB
        val largeString = "a".repeat(1_000_001)

        val exception = assertFailsWith<TemplateException.InputTooLarge> {
            templateEcho(largeString, null)
        }
        assertEquals(1_000_001UL, exception.size)
        assertEquals(1_000_000UL, exception.max)
    }

    @Test
    fun testEchoAtMaxSize() = runTest {
        // Create a string exactly at 1MB
        val maxString = "a".repeat(1_000_000)
        val result = templateEcho(maxString, null)
        assertTrue(result != null)
        assertEquals(maxString, result?.text)
    }
}
