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
        
        //Delete everything before starting the service
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: docPathString)
            
            //Clear everything in the docs directory
            for file in contents {
                do {
                    try fileManager.removeItem(atPath: docPathString + "/" + file)
                    print("Delete successful")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //This function handles creating file entries upon receiving directory content from the server
    func createFileEntries(specialString: String) {
        
        //Empty the current list and delete all files
        for fileEntry in availableFiles {
            do {
                try fileManager.removeItem(atPath: fileEntry.stringPath)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        //Remove all the current entries
        availableFiles.removeAll()
        
        let content = specialString.split(separator: "\r\n")
        
        //Model the content
        for newName in content {
            let newEntry = FileEntry(name: String(newName), availability: "remote", stringPath: "n/a")
            availableFiles.append(newEntry)
        }
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
    
    //Called to grab the file from a URL and place in the document directory
    func moveFile(tempUrl: URL, fileName: String) {
        //ls
        do {
            try print(fileManager.contentsOfDirectory(atPath: docPathString))
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        do {
            let destPath = docPathString + "/" + fileName + ".txt"
            try fileManager.moveItem(atPath: urlToString(url: tempUrl), toPath: destPath)
            
            //Model the change
            var i = 0
            for file in availableFiles {
                if file.name == fileName {
                    availableFiles[i].availability = "local"
                    availableFiles[i].stringPath = destPath
                }
                
                i = i + 1
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
