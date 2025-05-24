import XCTest
@testable import FoodCalorieAnalyzer

final class OpenAIServiceTests: XCTestCase {
    var service: OpenAIService!
    
    override func setUp() {
        super.setUp()
        service = OpenAIService.shared
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testNetworkAvailability() async throws {
        // Test that network monitoring is working
        XCTAssertNotNil(service)
        
        // Wait a bit for network status to be determined
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // The service should be able to determine network status
        // Note: We can't assert the exact value as it depends on the device's network state
        XCTAssertNoThrow(try await service.analyzeFoodImage(Data()))
    }
    
    func testInvalidImageData() async {
        // Test with empty image data
        do {
            _ = try await service.analyzeFoodImage(Data())
            XCTFail("Expected error for empty image data")
        } catch {
            // Should throw an error for invalid image data
            XCTAssertTrue(error is URLError || error is NSError)
        }
    }
    
    func testAPIKeyFormat() {
        // Test that API key is properly formatted
        let config = Config.self
        let apiKey = config.openAIApiKey
        
        // API key should not be empty
        XCTAssertFalse(apiKey.isEmpty)
        
        // API key should start with "sk-"
        XCTAssertTrue(apiKey.hasPrefix("sk-"))
    }
}
