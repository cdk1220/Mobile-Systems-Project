//
//  FileServerViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/17/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit

class FileServerViewController: UIViewController {
    
    //Storyboard attributes
    @IBOutlet weak var fileList: UITableView!
    @IBOutlet weak var createFileButton: UIButton!
    @IBOutlet weak var deleteFileButton: UIButton!
    
    var peerID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create file button setup
        createFileButton.layer.cornerRadius = 10
        
        //Delete file button setup
        deleteFileButton.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
