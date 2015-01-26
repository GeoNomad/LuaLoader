-- choose the strongest open AP available and connect to it
-- tested with NodeMcu 0.9.2 build 20150123

Tstart  = tmr.now()

ConnStatus = nil
function ConnStatus(n)
   status = wifi.sta.status()
   uart.write(0,' '..status)
   local x = n+1
   if (x < 50) and ( status < 5 ) then
      tmr.alarm(0,100,0,function() ConnStatus(x) end)
   else
      if status == 5 then
      print('\nConnected as '..wifi.sta.getip())
      dofile('httpget.lua')
      else
      print("\nConnection failed")
      end
   end
end
   
best_ssid = nil
function best_ssid(ap_db)
   local min = 100
   ssid = nil
   for k,v in pairs(ap_db) do
       if tonumber(v) < min then 
          min = tonumber(v)
          ssid = k
          end
       end
       
   gpio.write(red,gpio.LOW)
   gpio.write(blue,gpio.HIGH)
   return min
end


strongest = nil
function strongest(aplist)
   print("\nAvailable Open Access Points:\n")
   for k,v in pairs(aplist) do print(k..' '..v) end
   
   ap_db = {}
   if next(aplist) then
      for k,v in pairs(aplist) do 
         if '0' == string.sub(v,1,1) then 
            ap_db[k] = string.match(v, '-(%d+),') 
            end 
          end
      signal = -best_ssid(ap_db)
      end
   if ssid then
      print("\nBest SSID: ".. ssid)
      wifi.sta.config(ssid,"")
      print("\nConnecting to "..ssid)
      ConnStatus(0)
   else
      print("\nNo available open APs")
      ssid = ''
      end
end
    

wifi.setmode(wifi.STATION)
wifi.sta.getap(function(t) strongest(t)  end)
