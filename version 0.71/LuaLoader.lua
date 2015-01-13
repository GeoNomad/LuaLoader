-- LuaLoader Utility Functions
-- add dofile('LuaLoader.lua') to your init.lua

cat = nil
function cat( fname )
   file.open( fname, "r")
   local count = 0
   while true do
      local line = file.readline()
      if (line == nil) then break end
      count = count+1
      print(string.format("%3d", count)..':'..string.sub(line, 1, -2)) 
      tmr.wdclr()
      end
   file.close()
end
