-- http://benlo.com/esp8266/esp8266Projects.html#thebutton

Tstart  = tmr.now()
gpio.write(green,gpio.LOW)
gpio.write(blue,gpio.LOW)
gpio.write(red,gpio.HIGH)

ap_db[ssid] = nil

for k,v in pairs(ap_db) do
    print(k..','..v)
end



signal = -best_ssid(ap_db)
if ssid then
   print("\nBest SSID: ".. ssid)
   wifi.sta.config(ssid,"")
   print("\nConnecting to "..ssid)
   ConnStatus(0)
else
   print("\nFinished all available open APs")
   ssid = ''
   gpio.write(red,gpio.LOW)
   gpio.write(green,gpio.LOW)
   gpio.write(blue,gpio.LOW)
   end
