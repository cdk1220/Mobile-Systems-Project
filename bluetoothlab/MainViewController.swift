//
//  ViewController.swift
//  bluetoothlab
//
//  Created by Don Chalanga Kuruppu on 1/25/18.
//  Copyright © 2018 Don Chalanga Kuruppu. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController, UITextFieldDelegate {

    //Storyboard attributes
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var receivedTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var connectionDetails: UILabel!
    
    //Bluetooth central role attributes
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral!
    var successful: Bool!
    
    //Bluetooth peripheral role attributes
    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var transferService: CBMutableService!
    
    //Bluetooth advertising and subscribing attributes
    var advertisingString = "Hello there!"
    var dataToSend: Data!
    let transferServiceCBUUID = CBUUID(string: "7E1DF8E3-AA0E-4F16-B9AB-43B28D73AF26")
    let transferCharacteristicCBUUID = CBUUID(string: "7E1DF8E3-AA0E-4F16-B9AB-43B28D73AF25")

    override func viewDidLoad() {
        super.viewDidLoad()

        //Connection details label initialization settings
        connectionDetails.text = nil

        //Advertising text field initialization settings
        inputTextField.text = advertisingString
        inputTextField.delegate = self;
        
        //Connect button initialization settings
        connectButton.isHidden = true
        connectButton.layer.cornerRadius = 10
        
        //Disonnect button initialization settings
        disconnectButton.isHidden = true
        disconnectButton.layer.cornerRadius = 10
        
        //Bluetooth cental role initiation
        centralManager = CBCentralManager(delegate: self, queue: nil)
        successful = false
        
        //Bluetooth peripheral role initiation
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        //Creating service and characteristic
        transferCharacteristic = CBMutableCharacteristic(
            type: transferCharacteristicCBUUID,
            properties: [CBCharacteristicProperties.read, CBCharacteristicProperties.write, CBCharacteristicProperties.notify],
            value: nil,
            permissions: [CBAttributePermissions.readable, CBAttributePermissions.writeable]
        )
        transferService = CBMutableService(
            type: transferServiceCBUUID,
            primary: true
        )
        transferService.characteristics = [transferCharacteristic]
        dataToSend = advertisingString.data(using: String.Encoding.utf8)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Allow only 20 characters in the input text field so as not to advertise a string longer than 20 characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var startString = ""
        if (textField.text != nil) {
            startString += textField.text!
        }
        
        startString += string
        let limitNumber = startString.count
        
        if limitNumber > 20 {
            return false
        }
        else{
            return true;
        }
    }
    
    //When the user has done typing the advertising string, record the change
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        advertisingString = inputTextField.text ?? " "
        dataToSend = advertisingString.data(using: String.Encoding.utf8)
        transferCharacteristic.value = dataToSend
        peripheralManager.updateValue(dataToSend, for: transferCharacteristic, onSubscribedCentrals: nil)
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
        centralManager.connect(discoveredPeripheral)
        successful = false
        self.perform(#selector(connectionTimeout), with: nil, afterDelay: 5)
    }
    
    //Disconnect button tapped action handler
    @IBAction func disconnectTapped(_ sender: Any) {
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
    
    //Connection timeout method
    @objc func connectionTimeout() {
        if !successful {
            centralManager.cancelPeripheralConnection(discoveredPeripheral)
            connectButton.isHidden = true
            centralManager.scanForPeripherals(withServices: [transferServiceCBUUID])
        }
    }
}


//Functions that handle the central role when the app is central
extension MainViewController: CBCentralManagerDelegate {
    
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
            centralManager.scanForPeripherals(withServices: [transferServiceCBUUID])
        }
    }
    
    //When a peripheral is discovered, this gets triggered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        discoveredPeripheral = peripheral
        discoveredPeripheral.delegate = self
        centralManager.stopScan()
        connectButton.isHidden = false //Since there is a peripheral to connect to, display connect button
    }
    
    //When the cental manager fails to create a connection with a peripheral, this gets triggered
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("this gets called")
        connectButton.isHidden = true                                        //Failed to get connected to the chosen peripheral, therefore hide it
        centralManager.scanForPeripherals(withServices: [transferServiceCBUUID])   //Since the attempted connection failed try again
    }
    
    //When an existing connection to a peripheral is broken, this gets triggered
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnectButton.isHidden = true
        connectionDetails.text = nil
        centralManager.scanForPeripherals(withServices: [transferServiceCBUUID])
    }
    
    
    //When a connection with a peripheral is established, this gets triggered
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        connectionDetails.text = "Connected to " + peripheral.name!
        successful = true
        connectButton.isHidden = true          //Since there is a peripheral that the app is connected to, hide it
        disconnectButton.isHidden = false       //Since there is a connection to disconnect, make it appear
        discoveredPeripheral.discoverServices([transferServiceCBUUID])
    }
    
}


//Functions that handle the peripheral role when the app is central
extension MainViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            discoveredPeripheral.discoverCharacteristics([transferCharacteristicCBUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            discoveredPeripheral.setNotifyValue(true, for: characteristic)
            discoveredPeripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let stringFromData = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) else {
            print("Invalid data")
            return
        }
        receivedTextField.text = stringFromData as String
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        discoveredPeripheral.readValue(for: characteristic)
    }
}

extension MainViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("peripheral.state is .unknown")
        case .resetting:
            print("peripheral.state is .resetting")
        case .unsupported:
            print("peripheral.state is .unsupported")
        case .unauthorized:
            print("peripheral.state is .unauthorized")
        case .poweredOff:
            print("peripheral.state is .poweredOff")
        case .poweredOn:
            print("peripheral.state is .poweredOn")
            peripheralManager.add(transferService)
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [transferServiceCBUUID]])
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        // Set the correspondent characteristic's value
        // to the request
        request.value = dataToSend!
        
        // Respond to the request
        peripheralManager.respond(
            to: request,
            withResult: .success)
        
    }
    
}


