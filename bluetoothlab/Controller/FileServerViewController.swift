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
    @IBOutlet weak var openFileButton: UIButton!
    
    
    
    //To handle opening files
    var docController:UIDocumentInteractionController!
    
    var peerID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prepare server services
        ServerServices.serverServicesInstance.prepare()
        
        //Create file button setup
        createFileButton.layer.cornerRadius = 10
        
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
    
    //Create button action handler
    @IBAction func createButtonPressed(_ sender: Any) {
        ServerServices.serverServicesInstance.createAFile()
        fileList.reloadData()
    }
    
    //Delete button action handler
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let index = fileList.indexPathForSelectedRow
        
        //Delete if only something is selected
        if index != nil {
            let currentCell = fileList.cellForRow(at: index!)! as! ServerFileEntry
            
            var i = 0
            for file in ServerServices.serverServicesInstance.getFiles() {
                if currentCell.fileName.text == file.name {
                    ServerServices.serverServicesInstance.deleteFile(path: file.stringPath)
                    fileList.reloadData()
                    break
                }
                i = i + 1
            }
        }
    }
    
    //Open button action handler
    @IBAction func openButtonPressed(_ sender: Any) {
        let index = fileList.indexPathForSelectedRow
        
        //Open if only something is selected
        if index != nil {
            let currentCell = fileList.cellForRow(at: index!)! as! ServerFileEntry
            
            var i = 0
            for file in ServerServices.serverServicesInstance.getFiles() {
                if currentCell.fileName.text == file.name {
                    docController = UIDocumentInteractionController(url: ServerServices.serverServicesInstance.stringToUrl(stringPath: file.stringPath))
                    docController.presentOptionsMenu(from: self.openFileButton.frame, in: self.view, animated: true)
                    break
                }
                i = i + 1
            }
        }
    }
    
    
}
