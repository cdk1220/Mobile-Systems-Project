//
//  ClientServices.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/19/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import Foundation

class ClientServices {
    
    //Singleton
    static let clientServicesInstance = ClientServices()
    
    //List of files available to share
    private var availableFiles = [FileEntry]()
    
    //FileManager to carryout file related tasks
    private let fileManager = FileManager.default
    
    //URL to documents
    private var docURL: URL!
    
    //String path to documents
    private var docPathString: String!
    
    //This function prepares and initializes variables before using the services offered by the class
    func prepare() {
        //Getting the URL to documents
        docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        //Returns string path to documents
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        docPathString = paths[0]
    }
    
    //This function handles creating new files
    func createAFile(fileName: String, content: Data) {
        let path = docPathString + fileName + ".txt"                                           //Path to file
        let result = fileManager.createFile(atPath: path, contents: content, attributes: nil)  //Create file
        
        //Show results
        if result {
            print("File creation successful\n")
            
            //Entry was created when the directory structure was received. Edit it now.
            var i: Int
            for i in 0...availableFiles.count {
                if availableFiles[i].name  == fileName {
                    availableFiles[i].availability = "local"
                    availableFiles[i].stringPath = path
                }
            }
            
        }
        else {
            print("File creation unsuccessful\n")
        }
    }
    
    //This function handles creating file entries upon receiving directory content from the server
    func createFileEntries() {
        
    }
    
    //This function handles deleting files
    func deleteFile(path: String) {
        do {
            try fileManager.removeItem(atPath: path)
            
            //Remove file from list
            var i = 0
            for file in availableFiles {
                if file.stringPath == path {
                    availableFiles.remove(at: i)
                    print("File deletion successful\n")
                    break
                }
                
                i = i + 1
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //This function converts string paths to URLs
    func stringToUrl(stringPath: String) -> URL {
        return URL(fileURLWithPath: stringPath)
    }
    
    //This function converts URLs to string paths
    func urlToString(url: URL) -> String {
        return url.absoluteString.replacingOccurrences(of: "file://", with: "")
    }
    
    //Returns the available files as a list
    func getFiles() -> [FileEntry]{
        return self.availableFiles
    }
}
