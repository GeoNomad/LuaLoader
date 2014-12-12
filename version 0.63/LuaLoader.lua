-- LuaLoader Utility Functions
-- add dofile('LuaLoader.lua') to your init.lua

function cat( fname )
   file.open( fname, "r")
   while true do
      local line = file.readline()
      if (line == nil) then break end
      print(string.sub(line, 1, -2)) 
      end
   file.close()
end
