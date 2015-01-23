-- retrieve the current time from Google
-- tested on NodeMCU 0.9.5 build 20150108

conn=net.createConnection(net.TCP, 0) 

conn:on("connection",function(conn, payload)
            conn:send("HEAD / HTTP/1.1\r\n".. 
                      "Host: google.com\r\n"..
                      "Accept: */*\r\n"..
                      "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua;)"..
                      "\r\n\r\n") 
            end)
            
conn:on("receive", function(conn, payload)
    print('\nRetrieved in '..((tmr.now()-t)/1000)..' milliseconds.')
    print('Google says it is '..string.sub(payload,string.find(payload,"Date: ")
           +6,string.find(payload,"Date: ")+35))
    conn:close()
    end) 
t = tmr.now()    
conn:connect(80,'google.com') 
