import XCTest
@testable import Template

final class TemplateTests: XCTestCase {
    func testEchoWithValue() async throws {
        let result = try await echo(input: "Hello, World!", token: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.text, "Hello, World!")
        XCTAssertEqual(result?.length, 13)
    }

    func testEchoWithEmpty() async throws {
        let result = try await echo(input: "", token: nil)
        XCTAssertNil(result)
    }

    func testRandom() async throws {
        for _ in 0..<100 {
            let value = await random()
            XCTAssertGreaterThanOrEqual(value, 0.0)
            XCTAssertLessThan(value, 1.0)
        }
    }

    func testEchoWithLargeInput() async throws {
        // Create a string larger than 1MB
        let largeString = String(repeating: "a", count: 1_000_001)

        do {
            _ = try await echo(input: largeString, token: nil)
            XCTFail("Expected InputTooLarge error")
        } catch let error as TemplateError {
            guard case let TemplateError.InputTooLarge(size, max, hash) = error else {
                XCTFail("Expected InputTooLarge error, got \(error)")
                return
            }
            XCTAssertEqual(size, 1_000_001)
            XCTAssertEqual(max, 1_000_000)
            XCTAssertFalse(hash.isEmpty)
        }
    }

    func testEchoAtMaxSize() async throws {
        // Create a string exactly at 1MB
        let maxString = String(repeating: "a", count: 1_000_000)
        let result = try await echo(input: maxString, token: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.text, maxString)
        XCTAssertEqual(result?.length, 1_000_000)
    }
}
