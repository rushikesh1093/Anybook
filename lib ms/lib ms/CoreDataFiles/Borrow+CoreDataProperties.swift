//
//  Borrow+CoreDataProperties.swift
//  lib ms
//
//  Created by admin86 on 24/04/25.
//
//

import Foundation
import CoreData


extension Borrow {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Borrow> {
        return NSFetchRequest<Borrow>(entityName: "Borrow")
    }

    @NSManaged public var bookID: UUID
    @NSManaged public var borrowDate: Date
    @NSManaged public var dueDate: Date
    @NSManaged public var fine: Double
    @NSManaged public var id: UUID
    @NSManaged public var returnDate: Date?
    @NSManaged public var userID: UUID

}

extension Borrow : Identifiable {

}
