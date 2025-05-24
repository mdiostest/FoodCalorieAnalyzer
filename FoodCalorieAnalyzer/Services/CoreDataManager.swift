import CoreData
import Foundation

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
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Food Record Operations
    
    func saveFoodRecord(from analysis: FoodAnalysis, imageData: Data?) -> FoodRecord {
        let record = FoodRecord(context: context)
        record.id = analysis.id
        record.foodName = analysis.foodName
        record.calories = Int32(analysis.calories)
        record.protein = analysis.protein
        record.carbs = analysis.carbs
        record.fat = analysis.fat
        record.ingredients = analysis.ingredients as NSArray
        record.timestamp = analysis.timestamp
        record.imageData = imageData
        
        saveContext()
        return record
    }
    
    func fetchFoodRecords() -> [FoodRecord] {
        let request: NSFetchRequest<FoodRecord> = FoodRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FoodRecord.timestamp, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching food records: \(error)")
            return []
        }
    }
    
    func deleteFoodRecord(_ record: FoodRecord) {
        context.delete(record)
        saveContext()
    }
    
    func updateFoodRecord(_ record: FoodRecord) {
        saveContext()
    }
} 
