//
//  User+CoreDataProperties.swift
//  lib ms
//
//  Created by admin86 on 24/04/25.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String
    @NSManaged public var id: UUID
    @NSManaged public var isMember: Bool
    @NSManaged public var name: String
    @NSManaged public var role: String

}

extension User : Identifiable {

}
