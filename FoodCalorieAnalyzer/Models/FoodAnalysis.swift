import Foundation

struct FoodAnalysis: Codable, Identifiable {
    let id = UUID()
    let foodName: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let ingredients: [String]
    let timestamp: Date
    
    init(foodName: String, calories: Int, protein: Double, carbs: Double, fat: Double, ingredients: [String]) {
        self.foodName = foodName
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.ingredients = ingredients
        self.timestamp = Date()
    }
} 