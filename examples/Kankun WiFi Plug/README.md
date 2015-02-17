Kankun smart plug outlet controller

Full tutorial is at http://benlo.com/esp8266/KankunSmartPlug.html

<hr>

scp to the Kankun 

create /www/cgi-bin

chmod 755 cgi-bin

put relay.cgi in cgi-bin


<hr>
upload init.lua and httpget.lua to the esp8266


<hr>

/www/index.html and /www/click.mp3 are optional

They make a pretty toggle button for browser control of the Kandun outlet.

Browse to http://192.168.10.253 with any web browser.

The toggle will reflect the state of the Kandun switch as well as control it.



