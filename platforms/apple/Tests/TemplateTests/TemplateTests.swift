import XCTest
@testable import Template

final class TemplateTests: XCTestCase {
    func testHelloWorld() throws {
        let result = helloWorld()
        XCTAssertTrue(result)
    }

    func testEchoWithValue() throws {
        let result = try echo(input: "Hello, World!")
        XCTAssertEqual(result, "Hello, World!")
    }

    func testEchoWithEmpty() throws {
        let result = try echo(input: "")
        XCTAssertNil(result)
    }

    func testRandom() throws {
        for _ in 0..<100 {
            let value = random()
            XCTAssertGreaterThanOrEqual(value, 0.0)
            XCTAssertLessThan(value, 1.0)
        }
    }

    func testEchoWithLargeInput() throws {
        // Create a string larger than 1MB
        let largeString = String(repeating: "a", count: 1_000_001)

        XCTAssertThrowsError(try echo(input: largeString)) { error in
            guard case let UniffiTemplateError.InputTooLarge(message) = error else {
                XCTFail("Expected InputTooLarge error, got \(error)")
                return
            }
            XCTAssertTrue(message.contains("1000001"))
            XCTAssertTrue(message.contains("1000000"))
        }
    }

    func testEchoAtMaxSize() throws {
        // Create a string exactly at 1MB
        let maxString = String(repeating: "a", count: 1_000_000)
        let result = try echo(input: maxString)
        XCTAssertEqual(result, maxString)
    }
}
