//
//  FileClientViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/17/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit

class FileClientViewController: UIViewController {

    //Storyboard attributes
    @IBOutlet weak var fileList: UITableView!
    @IBOutlet weak var requestFileListButton: UIButton!
    @IBOutlet weak var downloadFileButton: UIButton!
    @IBOutlet weak var deleteFileButton: UIButton!
    
    var peerID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Request file button setup
        requestFileListButton.layer.cornerRadius = 10
        
        //Download file button setup
        downloadFileButton.layer.cornerRadius = 10
        
        //Delete file button setup
        deleteFileButton.layer.cornerRadius = 10
        
        
        
    }

    


}
