//
//  ViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 1/25/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate {

    //Storyboard attributes
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var receivedTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var centralManager: CBCentralManager!
    var genericPeripheral: CBPeripheral!
    let genericServiceCBUUID = CBUUID(string: "0x180D")
    let stringCharacteristicCBUUID = CBUUID(string: "2A3D")
    let defaultAdvertisingString = "Hello there!"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Advertising text field initialization settings
        inputTextField.text = defaultAdvertisingString
        inputTextField.delegate = self;
        
        //Buttons should be hidden before there is a viable connection
        connectButton.isHidden = true
        sendButton.isHidden = true
    
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Hide keyboard when the user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Hide keyboard when the user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder();
        return true
    }
    
    //Connect button tapped action handler
    @IBAction func connectTapped(_ sender: Any) {
        centralManager.connect(genericPeripheral)
        connectButton.isHidden = true
    }
    
}


//Functions that handle the central role when the app is central
extension ViewController: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectButton.isHidden = true
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectButton.isHidden = true
        centralManager.scanForPeripherals(withServices: [genericServiceCBUUID])
    }
 
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [genericServiceCBUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        genericPeripheral = peripheral
        genericPeripheral.delegate = self
        centralManager.stopScan()
        connectButton.isHidden = false //Since there is a peripheral to connect to, display connect button
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        genericPeripheral.discoverServices([genericServiceCBUUID])
    }
}


//Functions that handle the peripheral role when the app is central
extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case stringCharacteristicCBUUID:
            print(characteristic.value ?? "no value")
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}

