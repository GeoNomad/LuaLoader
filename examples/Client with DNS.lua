-- Simple webclient with DNS

-- http://www.esp8266.com/viewtopic.php?f=19&t=691

-- untested



file.remove("client.lua")
file.remove("client.lua")
file.open("client.lua","w+")
host="www.ernstc.dk"
ipnr=0
file.writeline([[tmr.alarm(30000, 1, function()]])
file.writeline([[sk=net.createConnection(net.TCP, 0)]])
file.writeline([[sk:dns(host,function(conn,ip) ]])
file.writeline([[ipnr=ip]])
file.writeline([[end)]])
file.writeline([[conn=net.createConnection(net.TCP, 0) ]])
file.writeline([[    conn:on("receive", function(conn, payload) print(payload) end )]])
file.writeline([[    conn:connect(80,ipnr)]])
file.writeline([[    conn:send("GET /esp.php?tekst="..adc.read(0) .."&heap="..node.heap().." HTTP/1.1\r\nHost: "..host.."\r\n"]])
file.writeline([[        .."Connection: keep-alive\r\nAccept: */*\r\n\r\n")]])
file.writeline([[end)]])
file.close()

