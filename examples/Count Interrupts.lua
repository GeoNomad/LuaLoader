-- Count pulses on GPIO2
 
count = 0
delay = 0
gpio.mode(9,gpio.INT,gpio.PULLUP)

function counter(level)
   x = tmr.now()
   if x > delay then
      delay = tmr.now()+250000
      count = count + 1
      print(count)
      end
   end
gpio.trig(9, "down",counter)

