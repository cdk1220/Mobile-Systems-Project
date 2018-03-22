//
//  ServerServices.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/17/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import Foundation

class ServerServices {
    
    //Singleton
    static let serverServicesInstance = ServerServices()
    
    //List of files available to share
    private var availableFiles = [FileEntry]()
    
    //FileManager to carryout file related tasks
    private let fileManager = FileManager.default
    
    //URL to documents
    private var docURL: URL!
    
    //String path to documents
    private var docPathString: String!
    
    //This is used when generating a new file. The name of the new file and the content inside this depend on this value
    private var fileNumber: Int = 1
    
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
        
        //Create 3 files as examples and store them
        for i in 1...3 {
            createAFile()
        }
    }
    
    //This function handles creating new files
    func createAFile() {
        let path = docPathString + "/file" + String(fileNumber) + ".txt"                    //Path to file
        let data = ("This file is file number " + String(fileNumber)).data(using: .utf8)    //Data that goes into the file
        
        let result = fileManager.createFile(atPath: path, contents: data, attributes: nil)  //Create file
        
        //Show results
        if result {
            print("File creation successful\n")
            
            //Model the file created and add to available list
            let newFile = FileEntry(name: "file" + String(fileNumber), availability: "n/a", stringPath: path)
            availableFiles.append(newFile)
        }
        else {
            print("File creation unsuccessful\n")
        }
        
        fileNumber = fileNumber + 1
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
    
    //This function creates a special string with the names of content in the directory
    func getDirectoryContentInSpecialString() -> String {
        var specialString: String = ""
        
        //Traverse through the available file list and fetch their names
        for file in availableFiles {
            specialString = specialString + file.name + "\r\n"
        }
        
        return specialString
    }
    
    //This function returns the path of the file given the name of the file
    func returnURLGivenTheName(nameGiven: String) -> URL {
        
        //Go through list and if there is a match return that
        for fileEntry in availableFiles {
            
            if fileEntry.name == nameGiven {
                return stringToUrl(stringPath: fileEntry.stringPath)
            }
        }
        
        return stringToUrl(stringPath: "")
    }
}
