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
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var connectionDetails: UILabel!
    
    //Bluetooth attributes
    var centralManager: CBCentralManager!
    var genericPeripheral: CBPeripheral!
    let genericServiceCBUUID = CBUUID(string: "0x180D") //Need to change this to the right kind
    let stringCharacteristicCBUUID = CBUUID(string: "2A3D")
    let defaultAdvertisingString = "Hello there!"
    var successful: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Connection details label initialization settings
        connectionDetails.text = nil

        //Advertising text field initialization settings
        inputTextField.text = defaultAdvertisingString
        inputTextField.delegate = self;
        
        //Connect button initialization settings
        connectButton.isHidden = true
        connectButton.layer.cornerRadius = 10
        
        //Disonnect button initialization settings
        disconnectButton.isHidden = true
        disconnectButton.layer.cornerRadius = 10
        
        //Bluetooth initiation
        centralManager = CBCentralManager(delegate: self, queue: nil)
        successful = false
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
        successful = false
        self.perform(#selector(connectionTimeout), with: nil, afterDelay: 5)
    }
    
    //Disconnect button tapped action handler
    @IBAction func disconnectTapped(_ sender: Any) {
        centralManager.cancelPeripheralConnection(genericPeripheral)
    }
    
    //Connection timeout method
    @objc func connectionTimeout() {
        if !successful {
            centralManager.cancelPeripheralConnection(genericPeripheral)
            connectButton.isHidden = true
            centralManager.scanForPeripherals(withServices: [genericServiceCBUUID])
        }
    }
    
    
}


//Functions that handle the central role when the app is central
extension ViewController: CBCentralManagerDelegate {
    
    //When the cental manager fails to create a connection with a peripheral, this gets triggered
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("this gets called")
        connectButton.isHidden = true                                       //Failed to get connected to the chosen peripheral, therefore hide it
        centralManager.scanForPeripherals(withServices: [genericServiceCBUUID])   //Since the attempted connection failed try again
    }
    
    //When an existing connection to a peripheral is broken, this gets triggered
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnectButton.isHidden = true
        connectionDetails.text = nil
        centralManager.scanForPeripherals(withServices: [genericServiceCBUUID])
    }
    
    //When the bluetooth status gets changed, this gets triggered
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
            let alert = UIAlertController(title: "Alert", message: "Turn bluetooth on!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [genericServiceCBUUID])
        }
    }
    
    //When a peripheral is discovered, this gets triggered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        genericPeripheral = peripheral
        genericPeripheral.delegate = self
        centralManager.stopScan()
        connectButton.isHidden = false //Since there is a peripheral to connect to, display connect button
    }
    
    //When a connection with a peripheral is established, this gets triggered
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        connectionDetails.text = "Connected to " + peripheral.name!
        successful = true
        connectButton.isHidden = true          //Since there is a peripheral that the app is connected to, hide it
        disconnectButton.isHidden = false       //Since there is a connection to disconnect, make it appear
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

