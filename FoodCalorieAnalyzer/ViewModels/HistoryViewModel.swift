import Foundation
import CoreData
import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var foodRecords: [FoodRecord] = []
    private let coreDataManager = CoreDataManager.shared
    
    func fetchFoodRecords(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<FoodRecord> = FoodRecord.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodRecord.timestamp, ascending: false)]
        
        do {
            foodRecords = try coreDataManager.viewContext.fetch(request)
        } catch {
            print("Error fetching food records: \(error)")
            foodRecords = []
        }
    }
    
    func deleteFoodRecord(_ record: FoodRecord) {
        coreDataManager.deleteFoodRecord(record)
        fetchFoodRecords(for: record.timestamp ?? Date())
    }
    
    func getTotalCalories(for date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<FoodRecord> = FoodRecord.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let records = try coreDataManager.viewContext.fetch(request)
            return records.reduce(0) { $0 + Int($1.calories) }
        } catch {
            print("Error calculating total calories: \(error)")
            return 0
        }
    }
    
    func getNutritionSummary(for date: Date) -> (protein: Double, carbs: Double, fat: Double) {
        let records = foodRecords
        let totalProtein = records.reduce(0.0) { $0 + $1.protein }
        let totalCarbs = records.reduce(0.0) { $0 + $1.carbs }
        let totalFat = records.reduce(0.0) { $0 + $1.fat }
        return (totalProtein, totalCarbs, totalFat)
    }
    
    func updateFoodRecord(_ record: FoodRecord) {
        coreDataManager.updateFoodRecord(record)
        fetchFoodRecords(for: record.timestamp ?? Date())
    }
} 