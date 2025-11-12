import XCTest
@testable import Template

final class ExtensionsTests: XCTestCase {

    // MARK: - Wrapper Functions Tests

    func testTemplateEcho() async throws {
        let result = try await templateEcho("Hello Extensions", token: nil)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.text, "Hello Extensions")
    }

    func testTemplateRandom() async throws {
        let value = await templateRandom()
        XCTAssertTrue((0.0..<1.0).contains(value))
    }

    // MARK: - EchoResult Extensions Tests

    func testEchoResultDescription() async throws {
        let result = try await echo(input: "test", token: nil)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.description.contains("test") ?? false)
    }

    func testEchoResultDate() async throws {
        let result = try await echo(input: "test", token: nil)
        XCTAssertNotNil(result)
        let date = result?.date
        XCTAssertNotNil(date)
        XCTAssertLessThanOrEqual(date?.timeIntervalSinceNow ?? 0, 1.0)
    }

    func testEchoResultFormattedHash() async throws {
        let result = try await echo(input: "test", token: nil)
        XCTAssertNotNil(result)
        if let formatted = result?.formattedHash {
            XCTAssertTrue(formatted.hasPrefix("0x"))
        }
    }

    // MARK: - TemplateError Extensions Tests

    func testErrorDetailedDescription() async throws {
        let largeString = String(repeating: "a", count: 1_000_001)

        do {
            _ = try await echo(input: largeString, token: nil)
            XCTFail("Expected TemplateError")
        } catch let templateError as TemplateError {
            let description = templateError.detailedDescription
            XCTAssertFalse(description.isEmpty)
            XCTAssertTrue(description.contains("exceeds"))
        }
    }

    func testErrorCode() async throws {
        let largeString = String(repeating: "a", count: 1_000_001)

        do {
            _ = try await echo(input: largeString, token: nil)
            XCTFail("Expected TemplateError")
        } catch let templateError as TemplateError {
            XCTAssertEqual(templateError.errorCode, "INPUT_TOO_LARGE")
        }
    }

    func testErrorIsRecoverable() async throws {
        let largeString = String(repeating: "a", count: 1_000_001)

        do {
            _ = try await echo(input: largeString, token: nil)
            XCTFail("Expected TemplateError")
        } catch let templateError as TemplateError {
            XCTAssertTrue(templateError.isRecoverable)
        }
    }

    // MARK: - CancellationToken Extensions Tests

    func testCancellationTokenIsActive() throws {
        let token = CancellationToken()
        XCTAssertTrue(token.isActive)

        token.cancel()
        XCTAssertFalse(token.isActive)
    }

    func testCancellationTokenWithTimeout() async throws {
        let token = CancellationToken.withTimeout(0.1)
        XCTAssertTrue(token.isActive)

        try await Task.sleep(nanoseconds: 150_000_000) // 150ms
        XCTAssertFalse(token.isActive)
    }

    // MARK: - TemplateConfig Extensions Tests

    func testTemplateConfigDefault() throws {
        let config = TemplateConfig.default
        XCTAssertEqual(config.maxInputSize(), 1_000_000)
        XCTAssertTrue(config.enableValidation())
    }

    func testTemplateConfigNoValidation() throws {
        let config = TemplateConfig.noValidation
        XCTAssertFalse(config.enableValidation())
    }

    func testTemplateConfigWithMaxSize() throws {
        let config = TemplateConfig.withMaxSize(5000)
        XCTAssertEqual(config.maxInputSize(), 5000)
        XCTAssertTrue(config.enableValidation())
    }

    func testTemplateConfigValidate() throws {
        let config = TemplateConfig.withMaxSize(10)

        // Should pass
        XCTAssertNoThrow(try config.validate("short"))

        // Should fail
        XCTAssertThrowsError(try config.validate("this is too long")) { error in
            XCTAssertTrue(error is TemplateError)
        }
    }

    // MARK: - Helper Functions Tests

    func testSafeTemplateOperationAsync() async throws {
        let result: TemplateResult<EchoResult?> = await safeTemplateOperationAsync {
            try await echo(input: "test", token: nil)
        }

        switch result {
        case .success(let value):
            XCTAssertNotNil(value)
            XCTAssertEqual(value?.text, "test")
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testSafeTemplateOperationAsyncWithError() async throws {
        let largeString = String(repeating: "a", count: 1_000_001)
        let result: TemplateResult<EchoResult?> = await safeTemplateOperationAsync {
            try await echo(input: largeString, token: nil)
        }

        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertEqual(error.errorCode, "INPUT_TOO_LARGE")
        }
    }
}
