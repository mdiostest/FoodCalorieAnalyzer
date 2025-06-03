import XCTest
@testable import FoodCalorieAnalyzer

class FoodCalorieAnalyzerUnitTests: XCTestCase {
    var viewModel: HistoryViewModel!
    
    override func setUpWithError() throws {
        viewModel = HistoryViewModel()
    }
    
    func testFoodAnalysis() {
        let analysis = FoodAnalysis(
            foodName: "Test Food",
            calories: 300,
            protein: 20.0,
            carbs: 30.0,
            fat: 10.0,
            ingredients: ["Test Ingredient 1", "Test Ingredient 2"]
        )
        
        XCTAssertEqual(analysis.foodName, "Test Food")
        XCTAssertEqual(analysis.calories, 300)
        XCTAssertEqual(analysis.protein, 20.0)
        XCTAssertEqual(analysis.carbs, 30.0)
        XCTAssertEqual(analysis.fat, 10.0)
        XCTAssertEqual(analysis.ingredients.count, 2)
    }
    
    func testNutritionSummary() {
        let date = Date()
        let summary = viewModel.getNutritionSummary(for: date)
        
        XCTAssertNotNil(summary)
        XCTAssertGreaterThanOrEqual(summary.protein, 0)
        XCTAssertGreaterThanOrEqual(summary.carbs, 0)
        XCTAssertGreaterThanOrEqual(summary.fat, 0)
    }
    
    func testTotalCalories() {
        let date = Date()
        let total = viewModel.getTotalCalories(for: date)
        
        XCTAssertGreaterThanOrEqual(total, 0)
    }
} 