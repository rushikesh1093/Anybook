//
//  Book+CoreDataProperties.swift
//  lib ms
//
//  Created by admin86 on 24/04/25.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var author: String
    @NSManaged public var bookDescription: String
    @NSManaged public var coverImage: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var genre: String
    @NSManaged public var id: UUID
    @NSManaged public var isbn: String
    @NSManaged public var isFavorite: Bool
    @NSManaged public var status: String
    @NSManaged public var title: String

}

extension Book : Identifiable {

}
