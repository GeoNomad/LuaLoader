-- tested on NodeMCU 0.9.5 build 20150123
-- sends info to http://benlo.com/esp8266/test.php
-- http://benlo.com/esp8266/esp8266Projects.html#thebutton

print('httpget.lua started')

conn = nil
conn=net.createConnection(net.TCP, 0) 

-- show the retrieved web page

conn:on("receive", function(conn, payload) 
     print(payload) 
     if string.match(payload, 'Button Received', 0) then   -- change this to the expected reply
        gpio.write(red,gpio.LOW)
        gpio.write(blue,gpio.LOW)
        gpio.write(green,gpio.HIGH)
     end
     end) 

-- when connected, request page (send parameters to a script)
conn:on("connection", function(conn, payload) 
     print('\nConnected') 
     conn:send("GET /esp8266/test.php?"          -- change this to your script
      .."TIME="..(tmr.now()-Tstart)
      .."&HEAP="..node.heap()
      .."&SSID="..ssid
      .."&SIG="..signal
      .."&ID="..node.chipid()..'.'..node.flashid()
      .." HTTP/1.1\r\n" 
      .."Host: benlo.com\r\n"                     -- change this to your host
	   .."Connection: close\r\n"
      .."Accept: */*\r\n" 
      .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
      .."\r\n")
     end) 
-- when disconnected, let it be known
conn:on("disconnection", function(conn, payload) 
      print('\nDisconnected') 
      tmr.alarm(0,3000,0,function()  
         gpio.write(red,gpio.LOW)
         gpio.write(green,gpio.LOW)
         gpio.write(blue,gpio.LOW)
         dofile('reconnect.lua')
         end)
      end)
                                             
conn:connect(80,'benlo.com')                       -- change this to your host

gpio.write(red,gpio.LOW)
gpio.write(green,gpio.LOW)
gpio.write(blue,gpio.HIGH)
