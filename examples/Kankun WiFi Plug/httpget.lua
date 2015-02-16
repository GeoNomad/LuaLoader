-- tested on NodeMCU 0.9.5 build 20150126
-- sends commands to Kankun WiFi button
-- http://benlo.com/esp8266/KankunSmartPlug.html

print('httpget.lua started')
print(node.heap())

conn = nil
conn=net.createConnection(net.TCP, 0) 

-- show the retrieved web page

conn:on("receive", function(conn, payload) 
     print(payload) 
     end) 

-- when connected, request page (send parameters to a script)
conn:on("connection", function(conn, payload) 
     print('\nConnected') 
     conn:send("GET /cgi-bin/relay.cgi?"
      .."toggle"
      .." HTTP/1.1\r\n" 
	   .."Connection: close\r\n"
      .."Accept: */*\r\n" 
      .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
      .."\r\n")
     end) 
-- when disconnected, let it be known
conn:on("disconnection", function(conn, payload) 
      print('\nDisconnected') 
      wifi.sta.disconnect()
      tmr.wdclr()      
      tmr.alarm(0,1000,0,function()
         print('all done')
         node.dsleep(600000000)  
         end)
      end)
                                             
conn:connect(80,'192.168.10.253') 
