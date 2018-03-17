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
    @IBOutlet weak var inputTextField: UITextField!       //As peripheral, the device would expose the string in this text field to be read as a characteristic
    @IBOutlet weak var receivedTextField: UITextField!    //As central, the device would populate this text field upon reading a peripheral's characteristic
    @IBOutlet weak var connectButton: UIButton!           //As central, the device would enable the user to connect to a peripheral that has been found by tapping this
    @IBOutlet weak var disconnectButton: UIButton!        //As central, the device would enable the user to cancel a connection with a peripheral by tapping thus
    @IBOutlet weak var connectionDetails: UILabel!        //As central, the device would display the name of the peripheral that it is connected to in this label
    
    //Bluetooth central role attributes
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral!
    var successful: Bool!                                 //Used to implement a connection timeout method for the central
    
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
        
        //Advertising string has to be converted to data before sending
        dataToSend = advertisingString.data(using: String.Encoding.utf8)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
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
        else {
            return true
        }
    }
    
    //When the user has modified the advertising, record the change and notify any connected centrals about said change
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


//Functions that handle the local central role
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
        discoveredPeripheral = peripheral
        discoveredPeripheral.delegate = self
        centralManager.stopScan()     //Can stop scanning as a device is found
        connectButton.isHidden = false //Since there is a peripheral to connect to, display connect button
    }
    
    //When the cental manager fails to create a connection with a peripheral, this gets triggered
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectButton.isHidden = true                                        //Failed to get connected to the chosen peripheral, therefore hide it
        centralManager.scanForPeripherals(withServices: [transferServiceCBUUID])   //Since the attempted connection failed try again
    }
    
    //When an existing connection to a peripheral is broken, this gets triggered
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnectButton.isHidden = true                                          //No need to display the disconnect button anymore as there is nothing to be disconnected from
        connectionDetails.text = nil                                             //Clear the connection details as there is no active connections
        receivedTextField.text = ""                                              //Since nothing is being received, clear what has already been received
        centralManager.scanForPeripherals(withServices: [transferServiceCBUUID])
    }
    
    //When a connection with a peripheral is established, this gets triggered
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionDetails.text = "Connected to " + peripheral.name!
        successful = true                    //Let the connection timeout method know the connection was successful
        connectButton.isHidden = true          //Since there is a peripheral that the app is connected to, hide it
        disconnectButton.isHidden = false       //Since there is a connection to disconnect, make it appear
        discoveredPeripheral.discoverServices([transferServiceCBUUID])
    }
    
}


//Functions that handle the remote peripheral role when the app is central
extension MainViewController: CBPeripheralDelegate {
    
    //Gets called when the service we desire has been found
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            discoveredPeripheral.discoverCharacteristics([transferCharacteristicCBUUID], for: service)
        }
    }
    
    //For a particular service, if it has the desired characteristic, this gets called
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            discoveredPeripheral.setNotifyValue(true, for: characteristic)   //Subscribe to the characteristic so that updates are received when the peripheral changes the characteristic
            discoveredPeripheral.readValue(for: characteristic)            //Try to read the value of the characteristic from the peripheral
        }
    }
    
    //The results of trying to read a peripheral characteristic, when arrived in the central, would call this function
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let stringFromData = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) else {
            return
        }
        receivedTextField.text = stringFromData as String
    }
    
    //When the peripheral let you know the characteristic has been updated, read the characteristic again
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        discoveredPeripheral.readValue(for: characteristic)
    }
}


//Functions that handle the local peripheral role
extension MainViewController: CBPeripheralManagerDelegate {
    
    //When the bluetooth status gets changed, this gets triggered
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
    
    //This is called when a central sends a read request
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        request.value = dataToSend!
        peripheralManager.respond(to: request, withResult: .success)
    }
    
    //This gets called when a central subscribes to receive update notifications of peripherals characteristics
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        peripheralManager.stopAdvertising()     //Stop the scanning as there is a central connected currently
    }
    
    //This gets called when a connected central unsubscribes a periphera's characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [transferServiceCBUUID]])      //Central was disconnected. Start scannng again
    }
    
}


