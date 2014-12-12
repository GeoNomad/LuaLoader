-- Servo Control by UDP

-- http://www.esp8266.com/viewtopic.php?f=19&t=794
-- untested

if(pl==nil) then
pl=1500
end
port=88
pin=9
srv=net.createServer(net.UDP)
srv:on("receive", function(srv, pl)
   print("Command Reveived")
   print(pl)
--servo code
gpio.mode(pin,gpio.OUTPUT)
tmr.alarm(20, 1, function()  
gpio.write(pin,gpio.HIGH)
tmr.delay(pl)
gpio.write(pin,gpio.LOW)
end)
 --servo code
   end)
srv:listen(port)

