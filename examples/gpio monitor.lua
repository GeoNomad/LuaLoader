-- monitor an input pin with output to the terminal


function monitor( pin )
   uart.write( 0, ''..gpio.read(pin) )
   end
   
gpio.mode(9,gpio.INPUT,gpio.PULLUP)

tmr.alarm( 50,1,function() monitor(9) end )

