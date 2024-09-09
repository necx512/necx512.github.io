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
![](/assets/images/2024-09-09_22-52_bluetoothservice.png)
