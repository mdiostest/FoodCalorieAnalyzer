import Foundation

struct FoodAnalysis: Codable, Identifiable {
    var id: UUID
    let foodName: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let ingredients: [String]
    let timestamp: Date
    
    init(id: UUID = UUID(), foodName: String, calories: Int, protein: Double, carbs: Double, fat: Double, ingredients: [String] = [], timestamp: Date = Date()) {
        self.id = id
        self.foodName = foodName
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.ingredients = ingredients
        self.timestamp = timestamp
    }
    
    var totalNutrients: Double {
        protein + carbs + fat
    }
    
    var proteinPercentage: Double {
        (protein / totalNutrients) * 100
    }
    
    var carbsPercentage: Double {
        (carbs / totalNutrients) * 100
    }
    
    var fatPercentage: Double {
        (fat / totalNutrients) * 100
    }
} 