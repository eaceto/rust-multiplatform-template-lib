import kotlin.test.Test
import kotlin.test.assertTrue
import uniffi.rust_multiplatform_template_lib.*

class TemplateTest {
    // LLM Tests (Candle-based)

    @Test
    fun testGetBackendInfo() {
        val info = getBackendInfo()
        assertTrue(info.isNotEmpty())
        assertTrue(info.contains("Candle backend"))
        assertTrue(info.contains("CPU threads"))
        assertTrue(info.contains("Platform"))
        println("Backend info: $info")
    }
}
