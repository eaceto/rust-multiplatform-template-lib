import XCTest
@testable import Template

final class TemplateTests: XCTestCase {
    // MARK: - LLM Tests (Candle-based)

    func testGetBackendInfo() throws {
        let info = try getBackendInfo()
        XCTAssertFalse(info.isEmpty)
        XCTAssertTrue(info.contains("Candle backend"))
        XCTAssertTrue(info.contains("CPU threads"))
        XCTAssertTrue(info.contains("Platform"))
        print("Backend info: \(info)")
    }
}
