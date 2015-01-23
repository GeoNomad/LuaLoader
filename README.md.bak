LuaLoader for Windows
=========

LuaLoader is a Windows program for uploading files to the ESP8266 and working with the Lua serial interface. It is compatible with all versions of Windows from Windows 95 to Windows 10.

The terminal window shows the output from the ESP8266 UART and lets you type or paste commands for immediate interpretation and execution.

A selection of buttons are available to automatically type often used commands and to select files for uploading to the ESP8266 file system.

The Buttons

All buttons have popup help information on mouse over. A few explanations follow:

<b>GPIO</b>. Set the IO pins to read or write. Change their values. Read values once or multiple times on a polling schedule. Read the ADC value.

Heap. Print the current Heap (RAM) available. A common cause of restarts is running out of RAM.

Restart. Perform a soft restart. The init.lua file is run automatically on restart.

chipID. Each chip has a unique ID that can be used in a multiple IoT environment.

tmr.stop. Stops one or more of the 7 timers. Right click to set which ones.

Set AP. Set the chip to STATION mode and set the Access Point SSID and Password. The ESP8266 will automatically connect to the access point. The information is saved and after a restart the chip will automatically reconnect within 2 seconds, normally.

Get IP. Get the currently assigned IP address, if any.

Wifi Status. Show the current status of the Wifi connection.

Disconnect. Disconnect from the access point.

Upload File... Upload a file from your hard drive to the ESP8266 in text mode or binary mode. The folder used is now designated as the current workspace and the folder name is added to the File - Workspace menu.

Upload Bin (or Text). Uploads the file named in the edit box below. Right click to select text or binary uploads. Binary uploads test each block with a checksum for data integrity and are faster. However, the LLbin() function in the LLbin.lua file must be loaded first.

File Selection. A dropdown list of files in the current workspace and on the ESP8266. Files on the ESP8266 are marked with a < character.

dofile. Executes the dofile() command to execute the file named in the text box above.

remove. Remove the file named in the text box from the ESP8266 file system.

cat. List the contents of the file named in the text box.

Format. Format the flash file system on the ESP8266. Deletes all the files. Format only works if you are running firmware built after 2015.01.05.

file.list. Lists the files in the ESP8266 flash file system. This list populates the drop down menu in the file name text box above.



LuaLoader is freeware.

The MIT License (MIT)

Copyright (c) 2015 Peter Jennings benlo.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
