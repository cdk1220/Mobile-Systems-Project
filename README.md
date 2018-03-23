# Mobile Systems (CSE 4340) - Semester Project

This is an iOS project with two phases. For the first phase, a simple application that leverages Bluetooth Low Energy (BLE) was created using CoreBluetooth. This application establishes a peer-to-peer communication channel that could be used to exchange an arbitrary string. It enables your iOS device to act as both a central and a peripheral simultaneously to enable the exchange.

The second phase of the project uses the BLE app from the first phase to advertise the IP address of the Wi-Fi interface of the iOS device. Once, the iOS device successfully sends its IP address to another iOS device, it is used to create a unique ID for a network service. For this phase, Apple's Multipeer Connectivity framework was used to simulate a client server network. In this phase, the server would be the iOS device that sent the IP address in phase one and it would advertise a service with the IP address sent in phase one as its unique ID. The client would be the iOS device that received the IP address in phase one and it would listen to services that are advertised with IP address received in phase one.

### Phase I Requirements

- Application successfully broadcasts its availability to nearby devices.
- Application scans for other available BT/BLE devices.
- Application successfully establish a connection.
- Application successfully exchange an arbitrary string.
- Application does not pre-designate one devices to be the server and the other a receiver.
- Both devices involved can act as both a client and a server with minimal manual configuration from user.


### Phase II Requirements

- Devices running the application connect over Wi-Fi successfully.
- Server  allows a client to browse the contents of a pre-designated directory.
- Client is able to request files from the server successfully.
- Client is able to download the requested file successfully.
- Client can request and download more files from the server over the same Wi-FI connection.


### Prerequisites

What things you need to install the software and how to install them

```
Xcode 9.2 or above
Any two iOS devices with iOS 11.2.5 or above
```

### Installing

- Double click on "MobileSystemsProject.xcodeproj" file to open up the project in Xcode.
- Click on the project navigator icon near the top left corner.
- Click on the "MobileSystemsProject.xcodeproj" file to open project settings.
- Under "General" tab, enter the details and sign in to your Apple account.
- Plug in your iOS device.
- Change your build device to the device that was just plugged in using the drop-down menu named "Set the active scheme."
- Click the play button near the top left corner. Upon Xcode complaining about not being able to launch the application, go to Settings -> General -> Device Management and click on "Trust."
- Click the play button on Xcode again. Now, the application should be seen running on your device.



## Authors

* **Don Kuruppu**


