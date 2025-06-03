import XCTest

class FoodCalorieAnalyzerUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testMainNavigation() throws {
        // Test tab navigation
        XCTAssertTrue(app.tabBars.buttons["Analyze"].exists)
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
        
        // Test switching tabs
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["Food History"].exists)
        
        app.tabBars.buttons["Analyze"].tap()
        XCTAssertTrue(app.navigationBars["Food Analyzer"].exists)
    }
    
    func testFoodAnalysis() throws {
        // Test food input
        let textField = app.textFields["Enter food name"]
        XCTAssertTrue(textField.exists)
        
        textField.tap()
        textField.typeText("Apple")
        
        // Verify analysis card appears
        XCTAssertTrue(app.staticTexts["Apple"].exists)
        XCTAssertTrue(app.staticTexts["cal"].exists)
    }
    
    func testHistoryView() throws {
        // Navigate to history
        app.tabBars.buttons["History"].tap()
        
        // Test date picker
        let datePicker = app.datePickers.firstMatch
        XCTAssertTrue(datePicker.exists)
        
        // Test list view
        let list = app.tables.firstMatch
        XCTAssertTrue(list.exists)
    }
} 