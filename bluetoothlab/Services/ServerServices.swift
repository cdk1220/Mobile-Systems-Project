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
    private var availableFiles = [
        FileEntry(name: "file1", availability: "n/a"),
        FileEntry(name: "file2", availability: "n/a"),
        FileEntry(name: "file3", availability: "n/a")
    ]
    
    //Returns the available files as a list
    func getFiles() -> [FileEntry]{
        return self.availableFiles
    }
}
