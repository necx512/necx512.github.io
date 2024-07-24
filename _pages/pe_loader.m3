---
layout: default
title: i3
description: Débuter sur i3.
---
# Why developing a PE loader?
As a pentester, I need to upload files on the machines that I want to test. However, it is common to see antivirus or EDRs that will detect and remove my tools. So I needed a way to bypass those security solutions.
There are a lot of technics to do (try?) it depending of what you want to do and what kind of protection you want to bypass. 

One of the technics is to transfer an encrypted malicious application on a machine, decrypt it directly in memory and then execute what you want.
Note that using encryption is not always a good case because some EDRs can flag a file a dangerous because it's entropy.

# What is a PE?
Basically a PE (Portable Executable) is the format of the binary application that can be executed on Windows.


