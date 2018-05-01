//
//  Part+CoreDataProperties.swift
//  Inventory
//
//  Created by Shane Talbert on 2/18/17.
//  Copyright © 2017 com.shane.talbert1@gmail. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Part {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Part> {
        return NSFetchRequest<Part>(entityName: "Part");
    }

    @NSManaged public var comments: String?
    @NSManaged public var created: NSDate?
    @NSManaged public var modelName: String?
    @NSManaged public var partDescription: String?
    @NSManaged public var partNumber: String?
    @NSManaged public var quantity: Int16

}
