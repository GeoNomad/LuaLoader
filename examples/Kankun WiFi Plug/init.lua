print('init.lua')
LLbin = nil

print(node.heap())

wifi.setmode(wifi.STATION)
wifi.sta.config("0K_SP3_BD4524","")

tmr.alarm(0,1000,0,function() dofile('httpget.lua') end)

