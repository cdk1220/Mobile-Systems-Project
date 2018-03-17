//
//  FileServerViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/17/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit

class FileServerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        
        fileList.dataSource = self
        fileList.delegate = self
    }

    //Number of rows in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ServerServices.serverServicesInstance.getFiles().count
    }
    
    //Populating the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = fileList.dequeueReusableCell(withIdentifier: "ServerFileEntry") as? ServerFileEntry {
            let serverFileEntry = ServerServices.serverServicesInstance.getFiles()[indexPath.row]
            cell.updateView(fileEntry: serverFileEntry)
            
            return cell
        }
        else {
            return ServerFileEntry()
        }
    }
}
