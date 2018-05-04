//
//  PartCell.swift
//  Inventory
//
//  Created by Shane Talbert on 2/18/17.
//  Copyright © 2017 com.shane.talbert1@gmail. All rights reserved.
//

import UIKit
import SwipeCellKit

class PartCell: SwipeTableViewCell {

    @IBOutlet weak var lblModelName: UILabel!
    @IBOutlet weak var lblPartDescription: UILabel!
    @IBOutlet weak var lblPartNumber: UILabel!
    
    
    func configureCell (part: Part) {
        lblModelName.text = part.modelName
        lblPartDescription.text = part.partDescription
        lblPartNumber.text = part.partNumber
        
    }
    
}
