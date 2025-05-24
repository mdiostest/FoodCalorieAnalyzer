import Foundation
import CoreData

class HistoryViewModel: ObservableObject {
    @Published var groupedRecords: [Date: [FoodRecord]] = [:]
    @Published var error: String?
    
    init() {
        loadRecords()
    }
    
    func loadRecords() {
        let records = CoreDataManager.shared.fetchFoodRecords()
        groupedRecords = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.timestamp ?? Date())
        }
    }
    
    func deleteRecord(_ record: FoodRecord) {
        CoreDataManager.shared.deleteFoodRecord(record)
        loadRecords()
    }
    
    func updateRecord(_ record: FoodRecord) {
        CoreDataManager.shared.updateFoodRecord(record)
        loadRecords()
    }
    
    func getTotalCalories(for date: Date) -> Int {
        let records = groupedRecords[date] ?? []
        return records.reduce(0) { $0 + Int($1.calories) }
    }
    
    func getNutritionSummary(for date: Date) -> (protein: Double, carbs: Double, fat: Double) {
        let records = groupedRecords[date] ?? []
        let totalProtein = records.reduce(0.0) { $0 + $1.protein }
        let totalCarbs = records.reduce(0.0) { $0 + $1.carbs }
        let totalFat = records.reduce(0.0) { $0 + $1.fat }
        return (totalProtein, totalCarbs, totalFat)
    }
} 