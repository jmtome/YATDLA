//
//  Item+CoreDataProperties.swift
//  Yatdl
//
//  Created by Juan Manuel Tome on 29/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var done: Bool
    @NSManaged public var title: String?
    @NSManaged public var colorString: String?
    @NSManaged public var parentCategory: Category?

}
