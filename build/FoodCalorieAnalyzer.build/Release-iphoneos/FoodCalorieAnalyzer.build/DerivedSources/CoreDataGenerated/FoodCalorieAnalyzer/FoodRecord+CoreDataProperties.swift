//
//  FoodRecord+CoreDataProperties.swift
//  
//
//  Created by Mriganka De on 03/06/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension FoodRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodRecord> {
        return NSFetchRequest<FoodRecord>(entityName: "FoodRecord")
    }

    @NSManaged public var calories: Int32
    @NSManaged public var carbs: Double
    @NSManaged public var fat: Double
    @NSManaged public var foodName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var imageData: Data?
    @NSManaged public var ingredients: [String]?
    @NSManaged public var protein: Double
    @NSManaged public var timestamp: Date?

}

extension FoodRecord : Identifiable {

}
