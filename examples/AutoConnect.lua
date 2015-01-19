-- choose the strongest open AP available and connect to it
-- Autoconnect to strongest AP
-- tested with NodeMcu 0.9.2 build 20141212 

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
   else
   print("\nConnection failed")
   end
end
end
   
best_ssid = nil
function best_ssid(ap_db)

local min = 100
for k,v in pairs(ap_db) do
    if tonumber(v) < min then 
       min = tonumber(v)
       ssid = k
       end
    end
end

best = nil
function best(aplist)

ssid = nil
print("\nAvailable Open Access Points:\n")
for k,v in pairs(aplist) do print(k..' '..v) end

ap_db = nil
ap_db = {}
if nil ~= next(aplist) then
     
   for k,v in pairs(aplist) do 
      if '0' == string.sub(v,1,1) then 
         ap_db[k] = string.match(v, '-(%d+),') 
         end 
       end
     
   if nil ~= next(ap_db) then
      best_ssid(ap_db)
      end
   end
if nil ~= ssid then
   print("\nBest SSID: ".. ssid)
   wifi.sta.config(ssid,"")
   print("\nConnecting to "..ssid)
   ConnStatus(0)
else
   print("\nNo available open APs")
   end
end
    

wifi.setmode(wifi.STATION)
wifi.sta.getap(function(t) best(t)  end)



