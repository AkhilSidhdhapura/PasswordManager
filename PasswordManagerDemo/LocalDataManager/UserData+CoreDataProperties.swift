//
//  UserData+CoreDataProperties.swift
//  PasswordManagerDemo
//
//  Created by Akhil Sidhdhapura on 25/03/25.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var email: Data?
    @NSManaged public var password: Data?
    @NSManaged public var accountName: String?

}

extension UserData : Identifiable {

}
