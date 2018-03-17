//
//  FileSharingViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 3/16/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit

class FileSharingViewController: UIViewController {
    
    var currentRole: String?

    @IBOutlet weak var role: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        role.text = currentRole
        print(currentRole!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
