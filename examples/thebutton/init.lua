-- thebutton http://benlo.com/esp8266/esp8266Projects.html#thebutton

print('init.lua')

wifi.setmode(wifi.STATION)

red = 7
blue = 5
green = 6

gpio.mode(red,gpio.OUTPUT)
gpio.mode(green,gpio.OUTPUT)
gpio.mode(blue,gpio.OUTPUT)
gpio.write(red,gpio.HIGH)
gpio.write(green,gpio.LOW)
gpio.write(blue,gpio.LOW)

tmr.alarm(0,1000,0,function() dofile('autoconnect.lua') end)

