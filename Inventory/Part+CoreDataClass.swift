//
//  Part+CoreDataClass.swift
//  Inventory
//
//  Created by Shane Talbert on 2/18/17.
//  Copyright © 2017 com.shane.talbert1@gmail. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(Part)
public class Part: NSManagedObject {
    
    //Class was generated from xc datamodeled
    
    //Creating the time stamp
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.created = NSDate()
    }

}
