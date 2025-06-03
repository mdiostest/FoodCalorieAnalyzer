import Foundation
import CoreData
import SwiftUI
// If needed, import the app module for FoodRecord
// import FoodCalorieAnalyzer

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        // Register the transformer for [String] type
        let transformer = NSSecureUnarchiveFromDataTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName("NSSecureUnarchiveFromData"))
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FoodCalorieAnalyzer")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Food Record Operations
    
    func createFoodRecord(from analysis: FoodAnalysis) -> FoodRecord {
        let record = FoodRecord(context: viewContext)
        record.id = UUID()
        record.foodName = analysis.foodName
        record.calories = Int32(analysis.calories)
        record.protein = analysis.protein
        record.carbs = analysis.carbs
        record.fat = analysis.fat
        record.timestamp = Date()
        record.ingredients = analysis.ingredients
        saveContext()
        return record
    }
    
    func fetchFoodRecords(for date: Date) -> [FoodRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<FoodRecord> = FoodRecord.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodRecord.timestamp, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching food records: \(error)")
            return []
        }
    }
    
    func deleteFoodRecord(_ record: FoodRecord) {
        viewContext.delete(record)
        saveContext()
    }
    
    func updateFoodRecord(_ record: FoodRecord) {
        saveContext()
    }
} 
