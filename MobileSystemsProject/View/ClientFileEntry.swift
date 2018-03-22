//
//  ClientFileEntry.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/17/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit

class ClientFileEntry: UITableViewCell {
    
    //Cell properties from storyboard
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var availability: UILabel!
    
    func updateView(fileEntry: FileEntry) {
        fileName.text = fileEntry.name
        availability.text = fileEntry.availability
    }
}
