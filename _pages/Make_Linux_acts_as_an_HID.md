---
layout: default
title: Make Linux acts as an HID 
description: Débuter sur i3.
---


Some days ago, I opened my laptop and due to a kind of Murphy's law, the keyboard did not work.

Obviously, I put an external USB keyboard but because I love to learn and doing useless things, I wondered if it is possible to use my rasperry pi(or any other computer based on Linux) as a bluetooth keyboard.

Of course, my first though was: "Is there any existing open source projects that do what I want?". Not surprisigly, the answer is yes. 

However, and probably because I'm not a smart guy, I had some difficulties to make those projects works. More importantely, reading the code reveals some mysterious hardcoded values and I wanted to understand what those values are. This led me to do more search arround bluetooth specifications and other stuff.

# HID
The title of this post is about HID, but what is an HID?
Well, this is simple: HID stands for Human Interface Device. Any devices that can be used by a human to send input to a computer can be seen as an HID. A mouse is then an HID. A keyboard, a joystick are also HIDs.
HID are one of the classes of devices in the blootooth specification.

# Bluez 
Bluez is the bluetooth stack for linux[1].
I did not want to implement a full bluetooth stack ( not yet ;) ). Using it's existing stack allows me to abtract the low level things of the protocol.
If you used to use Linux, you probably know the bluetooth service:
![bluetooth service](/assets/images/2024-09-09_22-52_bluetoothservice.png)

Once active, you can interract with it with the `bluetoothctl` command. For example, we can discover available devices with the scan on command. The following screen show my device.
![bluetoothctl](/assets/images/2024-09-09_23-06_bluetoothctl.png)

Let's try to connect to this device with the command connect [MAC]:
![Failed to connect](/assets/images/2024-09-09_23-08_bluetoothctl_failed.png)

As you can see, the connect command failed. This is the expected behaviour because you need to pair with the device (with the pair command) before try to connect to it.

The reason I wanted to show you this error is because of its format. You can see the stringorg.bluez.Error.Failed . If you don't know: such string is specific to DBUS, meaning that bluetoothctl use DBUS. But, wait… What is DBUS?

# DBUS
On linux, processes can communicates through multiple ways such as sockets, shared memory, named pipe or… DBUS!

You can simply see DBUS as a virtual bus on which multiple processes connect to in order to send or receive messages each other

![DBUS](/assets/images/2024-09-09_23-10_dbus.png)

Each process are identified by a so called 'Well-known bus name'. From the previous error, `org.bluez` is the well-known bus name for the bluetooth service:

![busctl](/assets/images/2024-09-09_23-12_busctl.png)

## Objects and Interfaces
`org.bluez` refers to the bluetooth service on DBUS. The service expose multiple objects which are named with a linux-like path. For example, the well-known bus 'org.bluez' has an object called '/org/bluez'

![busctl](/assets/images/2024-09-09_23-13_qdbus.png)
Each object has multiple interfaces. Some exemples of interfaces provided bt the object '/org/bluez':
- org.bluez.Agent
- org.bluez.Adapter
- org.bluez.ProfileManager1 (https://github.com/bluez/bluez/blob/master/doc/org.bluez.ProfileManager.rst)

Finally, earch interface provide some function you can call. In our case, we will use the functions exported by the interfaces of the /org/bluez object to interact with the bluetooth service.

# Specifications documents
Before going further, let me give you important documents
## Bluetooth
Knowing we need to use dbus to communicate with bluez is not enough. Indeed, there is no magical functions createMyKeyboardDevice.
Thus, we need to learn a little bit more about how to create an bluetooth HID device. The better place to do that is the official website that provides the bluetooth specifications:
https://www.bluetooth.com/specifications/specs/

There is not one document in this page but many. The first time I saw that, I was lost. So let me explain some basics.
### Status
First, there is an important column name called 'status' and 'Version/Revision'

![spec bluetooth](/assets/images/2024-09-09_23-16_status.png)

If you look carefully, there are documents with the same name. Some of those document are old, so it is important to look for the most recent one.

Moreover, some of those documents have a deprecated status. This is important to select the documents with 'Adopted' status

## Important documents
There is two important documents. The first one is the core bluetooth specification. This will gives you some important generic informations

![spec bluetoothcore](/assets/images/2024-09-09_23-18_core.png)

Among all other document, there is one that seems to be interresting for us: The Human Interface Device Profile.

![spec bluetoothhid](/assets/images/2024-09-09_23-19_hid.png)


# SPD
Bluetooth specification describes SDP.
> SDP database which consists of a list of service records that describe the characteristics of services associated with the server. Each service record contains information about a single service.

> All of the information about a service that is maintained by an SDP Server is contained within a single service record. The service record shall only be a list of service attributes.

![spec bluetoothhid](/assets/images/2024-09-09_23-23_24_sdp.png)

> An attribute ID is a 16-bit unsigned integer

> A service class definition specifies each of the attribute IDs for a service class and assigns a meaning to the attribute value associated with each attribute ID. Each attribute ID is defined to be unique only within each service class

> A service record contains attributes that are specific to a service class as well as universal attributes that are common to all services


SPD attributes is splitted into two categories : Universal attributes and Specific attributes.

## attributes ID
Universal attributes is defined in the bluetooth specification "Assigned Numbers", section 5.1.5 "Bluetooth Core Specification: Universal Attributes":
![spec bluetoothhid](/assets/images/2024-09-13_22-51_univattributes.png)

### ServiceClassIDList (0x0001)
The bluetooth core specification gives the details of each attributes:
![spec bluetoothhid](/assets/images/2024-09-13_23-15_serviceclassidlist.png)

### ProtocolDescriptorList (0x0004)
The bluetooth core specification gives the details of each attributes:
![spec bluetoothhid](/assets/images/2024-09-13_23-22_protocoldescriptolist.png)

### BrowseGroupList (0x0005)
The bluetooth core specification gives the details of each attributes:
![spec bluetoothhid](/assets/images/2024-09-13_23-24_browsegrouplist.png)

### LanguageBaseAttributeIDList (0x0006)
The bluetooth core specification gives the details of each attributes
![spec bluetoothhid](/assets/images/2024-09-13_23-29_languagebaseattributeidlist.png)

### BluetoothProfileDescriptorList (0x0009)
The bluetooth core specification gives the details of each attributes
![spec bluetoothhid](/assets/images/2024-09-13_23-34_bluetoothProfileDescriptorlist.png)

### AdditionalProtocolDescriptorLists (0x000d)
The bluetooth core specification gives the details of each attributes
![spec bluetoothhid](/assets/images/2024-09-13_23-37_additionalprotocoldescriptorlists.png)

## attribute ID Offsets
The same specification also describe the attribute ID Offsets for Strings

![spec bluetoothhid](/assets/images/2024-09-13_22-51_attributesIDOffsetsforStrings.png)

### ServiceName attribute
The bluetooth core specification gives the details of each attributes

![spec bluetoothhid](/assets/images/2024-09-13_23-42_servicename.png)

### ServiceDescription attribute
The bluetooth core specification gives the details of each attributes

![spec bluetoothhid](/assets/images/2024-09-13_23-43_servicedescription.png)

### ServiceDescription attribute
The bluetooth core specification gives the details of each attributes

![spec bluetoothhid](/assets/images/2024-09-13_23-47_providername.png)


## DID

The same specification also describe the Device Identification Profile:

![spec bluetoothhid](/assets/images/2024-09-13_23-09_did.png)

### SpecificationID (0x0200)
The bluetooth device identification profile specification give the details of each attribute

![spec bluetoothhid](/assets/images/2024-09-14_00-04_specificationID.png)

### VendorID (0x0201)
The bluetooth device identification profile specification give the details of each attribute

![spec bluetoothhid](/assets/images/2024-09-14_00-06_vendorid.png)

### ProductID (0x0202)
The bluetooth device identification profile specification give the details of each attribute

![spec bluetoothhid](/assets/images/2024-09-14_00-07_productID.png)

### Version (0x0203)
The bluetooth device identification profile specification give the details of each attribute

![spec bluetoothhid](/assets/images/2024-09-14_00-18_version.png)

### PrimaryRecord (0x0204)
The bluetooth device identification profile specification give the details of each attribute

![spec bluetoothhid](/assets/images/2024-09-14_00-20_Primaryrecord.png)

### VendorIDSource (0x0205)
The bluetooth device identification profile specification give the details of each attribute

![spec bluetoothhid](/assets/images/2024-09-14_00-21_vendorIDSource.png)

### HIDDescriptorList (0x0206)
The bluetooth HUMAN INTERFACE DEVICE PROFILE 1.1 specification give the details of this attribute

![spec bluetoothhid](/assets/images/2024-09-14_01-17_hiddescriptorlist.png)

### HIDLANGIDBaseList (0x0207)
The bluetooth HUMAN INTERFACE DEVICE PROFILE 1.1 specification give the details of this attribute

![spec bluetoothhid](/assets/images/2024-09-14_01-27_hidlangidbaselist.png)

### HIDProfileVersion 0x020B 
The bluetooth HUMAN INTERFACE DEVICE PROFILE 1.1 specification give the details of this attribute
DEPRECATED

![spec bluetoothhid](/assets/images/2024-09-14_01-31_hidprofileverion.png)

### HIDSupervisionTimeout (0x020c) 
The bluetooth HUMAN INTERFACE DEVICE PROFILE 1.1 specification give the details of this attribute

![spec bluetoothhid](/assets/images/2024-09-14_01-34_hidsupervisiontimeout.png)

### HIDNormallyConnectable (0x020d) 
The bluetooth HUMAN INTERFACE DEVICE PROFILE 1.1 specification give the details of this attribute

![spec bluetoothhid](/assets/images/2024-09-14_01-35_hidnormallyconnectable.png)

### HIDBootDevice (0x020e) 
The bluetooth HUMAN INTERFACE DEVICE PROFILE 1.1 specification give the details of this attribute

![spec bluetoothhid](/assets/images/2024-09-14_01-40_HIDBootDevice.png)

### HIDSSRHostMaxLatency (0x020f) 
The bluetooth HUMAN INTERFACE DEVICE PROFILE 1.1 specification give the details of this attribute

![spec bluetoothhid](/assets/images/2024-09-14_01-41_hidssrhostmaxlatency.png)

### HIDSSRHostMinTimeout (0x0210)
The bluetooth HUMAN INTERFACE DEVICE PROFILE 1.1 specification give the details of this attribute

![spec bluetoothhid](/assets/images/2024-09-14_01-43_hidssrhostmintimeout.png)





# USB

The USB Device Class Definition for Human Interface Devices (HID) Specification describe tag, ite

![spec bluetoothhid](/assets/images/2024-09-14_16-33_btypebsize.png)
![spec bluetoothhid](/assets/images/2024-09-14_16-33_btypebsizelong.png)
![spec bluetoothhid](/assets/images/2024-09-14_16-35_mainitem.png)
![spec bluetoothhid](/assets/images/2024-09-14_16-36_globalitem.png)
![spec bluetoothhid](/assets/images/2024-09-14_16-37_localitem.png)


<table>
<tr>
<th>Main (xxxx 00 nn)</th>
<th>Global(xxxx 01 nn)</th>
<th>Local (xxxx 10 nn)</th>
</tr>

<tr>
<td>Input (1000 00 nn) </td>
<td>Usage Page (0000 01 nn)</td>
<td>Usage (0000 10 nn)</td>
</tr>

<tr>
<td>Output (1001 00 nn)</td>
<td>Logical Minimum (0001 01 nn)</td>
<td>Usage Minimum (0001 10 nn)</td>
</tr>

<tr>
<td>Feature (1011 00 nn)</td>
<td>Logical Maximum (0010 01 nn)</td>
<td>Usage Maximum (0010 10 nn)</td>
</tr>

<tr>
<td>Collection (1010 00 nn)</td>
<td>Physical Minimum (0011 01 nn)</td>
<td></td>
</tr>

<tr>
<td>End of Collection( 1100 00 nn)</td>
<td>Physical Maximum (0100 01 nn)</td>
<td></td>
</tr>

<tr>
<td></td>
<td>Report Size (0111 01 nn)</td>
<td></td>
</tr>

<tr>
<td></td>
<td>Report ID</td>
<td></td>
</tr>

<tr>
<td></td>
<td>Report Count</td>
<td></td>
</tr>

<tr>
<td></td>
<td>Report Push</td>
<td></td>
</tr>

<tr>
<td></td>
<td>Report Pop</td>
<td></td>
</tr>

</table>

# Transfer
The way a device send data to the host is described in section '3.1.2.9 DATA' of the bluetooth human interface device profile 1.1 specification:
![spec bluetoothhid](/assets/images/2024-09-13_22-17_transfer.png)

# References
- 1 https://github.com/torvalds/linux/blob/master/net/bluetooth/lib.c
- 2 https://docs.kernel.org/hid/hidintro.html
- 3 https://www.youtube.com/watch?v=1kfUYj2Yilg
- 4 https://programel.ru/files/Tutorial%20about%20USB%20HID%20Report%20Descriptors%20_%20Eleccelerator.pdf
- 5 https://stackoverflow.com/questions/65497619/making-linux-into-a-bluetooth-keyboard-hid
- 6 https://docs.silabs.com/protocol-usb/1.2.0/protocol-usb-hid/

