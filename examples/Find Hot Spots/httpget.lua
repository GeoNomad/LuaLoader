-- tested on NodeMCU 0.9.5 build 20150123
-- sends info to http://benlo.com/esp8266/test.php

print('httpget.lua started')

conn = nil
conn=net.createConnection(net.TCP, 0) 

-- show the retrieved web page

conn:on("receive", function(conn, payload) 
     print(payload) 
     if string.match(payload, 'Test Number', 0) then
        gpio.write(blue,gpio.LOW)
        gpio.write(green,gpio.HIGH)
     else
        gpio.write(red,gpio.HIGH)
        end
     end) 

-- when connected, request page (send parameters to a script)
conn:on("connection", function(conn, payload) 
     print('\nConnected') 
     conn:send("GET /esp8266/test.php?"
      .."TIME="..(tmr.now()-Tstart)
      .."&HEAP="..node.heap()
      .."&SSID="..ssid
      .."&SIG="..signal
      .."&ID="..node.chipid()..'.'..node.flashid()
      .." HTTP/1.1\r\n" 
      .."Host: benlo.com\r\n" 
	   .."Connection: close\r\n"
      .."Accept: */*\r\n" 
      .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
      .."\r\n")
     end) 
-- when disconnected, let it be known
conn:on("disconnection", function(conn, payload) 
      print('\nDisconnected') 
      tmr.alarm(0,5000,0,function()  
         gpio.write(red,gpio.LOW)
         gpio.write(green,gpio.LOW)
         gpio.write(blue,gpio.LOW)
         end)
      end)
                                             
conn:connect(80,'benlo.com') 
