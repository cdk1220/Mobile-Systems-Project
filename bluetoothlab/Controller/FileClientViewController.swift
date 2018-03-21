//
//  FileClientViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/17/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class FileClientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {

    //Storyboard attributes
    @IBOutlet weak var fileList: UITableView!
    @IBOutlet weak var requestListOfFilesButton: UIButton!
    @IBOutlet weak var downloadFileButton: UIButton!
    @IBOutlet weak var openFileButton: UIButton!
    @IBOutlet weak var deleteFileButton: UIButton!
    
    //To handle opening files
    var docController: UIDocumentInteractionController!
    
    //Variables used for communication
    var session : MCSession!                    //Creates a session for communication
    var serviceID: String!                      //The uuid of the service you are listening to
    var peerID: MCPeerID!                       //Your device ID
    var browser : MCBrowserViewController!      //Used to search for the service you want to listen to
    
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
    
    //Open button action handler
    @IBAction func openButtonPressed(_ sender: Any) {
        let index = fileList.indexPathForSelectedRow
        
        //Open if only something is selected
        if index != nil {
            let currentCell = fileList.cellForRow(at: index!)! as! ClientFileEntry
            
            //Check if the file is available locally, before opening it
            if currentCell.availability.text == "local" {
                var i = 0
                for file in ClientServices.clientServicesInstance.getFiles() {
                    if currentCell.fileName.text == file.name {
                        docController = UIDocumentInteractionController(url: ClientServices.clientServicesInstance.stringToUrl(stringPath: file.stringPath))
                        docController.presentOptionsMenu(from: self.openFileButton.frame, in: self.view, animated: true)
                        break
                    }
                    i = i + 1
                }
            }
            else {
                let alert = UIAlertController(title: "Alert", message: "Download file first!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    //Delete button action handler
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let index = fileList.indexPathForSelectedRow
        
        //Delete if only something is selected
        if index != nil {
            let currentCell = fileList.cellForRow(at: index!)! as! ClientFileEntry
            
            //Deleting only what's local
            if currentCell.availability.text == "local" {
                var i = 0
                for file in ClientServices.clientServicesInstance.getFiles() {
                    if currentCell.fileName.text == file.name {
                        ClientServices.clientServicesInstance.deleteFile(path: file.stringPath)
                        fileList.reloadData()
                        break
                    }
                    i = i + 1
                }
            }
            else {
                let alert = UIAlertController(title: "Alert", message: "Download file first!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
   
    @IBAction func requestListButtonPressed(_ sender: Any) {
        //Get file list from server
        //Make obejcts with remote availability
        //Reload the table
    }
    @IBAction func downloadButtonPressed(_ sender: Any) {
        //Request file content
        //Create file and save it
        //Edit the list
        //Reload the table
    }
    
    //Gets executed when the connection with server gets dropped
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    //When server sends data, this gets called
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //Directory structure will be received in here
    }
    
    //Gets called when server opens a stream
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    //WHen server starts sending a file this gets called
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    //WHen server is done sending the file this gets called
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //Downloaded file will be received here. Use the given URL to grab file
    }
    
    //Gets called when you press done in browser view controller
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
    }
    
    //Gets called when you press cancel in browser view controller
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
    }
    
}
