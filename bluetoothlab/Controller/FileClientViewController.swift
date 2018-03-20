//
//  FileClientViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/17/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit

class FileClientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Storyboard attributes
    @IBOutlet weak var fileList: UITableView!
    @IBOutlet weak var requestListOfFilesButton: UIButton!
    @IBOutlet weak var downloadFileButton: UIButton!
    @IBOutlet weak var openFileButton: UIButton!
    @IBOutlet weak var deleteFileButton: UIButton!
    
    //To handle opening files
    var docController:UIDocumentInteractionController!
    
    var peerID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ClientServices.clientServicesInstance.prepare()

        //Request file button setup
        requestListOfFilesButton.layer.cornerRadius = 10
        
        //Download file button setup
        downloadFileButton.layer.cornerRadius = 10
        
        //Delete file button setup
        deleteFileButton.layer.cornerRadius = 10
        
        //Open file button setup
        openFileButton.layer.cornerRadius = 10
        
        //Preparing table view
        fileList.dataSource = self
        fileList.delegate = self
    }

    //Number of rows in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ClientServices.clientServicesInstance.getFiles().count
    }
    
    //Populating the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = fileList.dequeueReusableCell(withIdentifier: "ClientFileEntry") as? ClientFileEntry {
            let clientFileEntry = ClientServices.clientServicesInstance.getFiles()[indexPath.row]
            cell.updateView(fileEntry: clientFileEntry)
            
            return cell
        }
        else {
            return ClientFileEntry()
        }
    }


}
