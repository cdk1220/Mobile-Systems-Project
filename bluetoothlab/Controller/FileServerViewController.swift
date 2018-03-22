//
//  FileServerViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/17/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class FileServerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MCSessionDelegate {
 
    //Storyboard attributes
    @IBOutlet weak var fileList: UITableView!
    @IBOutlet weak var createFileButton: UIButton!
    @IBOutlet weak var deleteFileButton: UIButton!
    @IBOutlet weak var openFileButton: UIButton!
    
    //To handle opening files
    var docController: UIDocumentInteractionController!
    
    //Variables used for communication
    var assistant : MCAdvertiserAssistant!      //Used to advertise the service you have
    var session : MCSession!                    //Creates a session for communication
    var serviceID: String = ""                  //The uuid of the service you are creating
    var peerID: MCPeerID!                       //Your device ID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(serviceID)
        
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
        
        //Preparing for communication
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        self.assistant = MCAdvertiserAssistant(serviceType: serviceID, discoveryInfo: nil, session: self.session)
        self.assistant.start()
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
        
        //Reloading should be done on the main thread
        DispatchQueue.main.async {
            self.fileList.reloadData()
        }
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
                    
                    //Reloading should be done on the main thread
                    DispatchQueue.main.async {
                        self.fileList.reloadData()
                    }
                    
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
    
    //Gets executed when the connection with a client gets dropped
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    //When client requests in the form of data get received, this gets called
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let stringReceived = String.init(data: data, encoding: String.Encoding.utf8)
        
        //If received string is 'directory,' that means client wants directory content
        if stringReceived == "Directory" {
            let specialString = ServerServices.serverServicesInstance.getDirectoryContentInSpecialString()
            
            do {
                try self.session.send(specialString.data(using: .utf8)!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
       
    }
    
    //Gets called when client streams are received
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    //If a client starts sending a file (won't happen, just there because of being session delegate) this gets executed
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    //WHen a client finished sending a file (won't happen, just there because of being session delegate) this gets executed
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}
