local lapis = require("lapis")
local db = require("lapis.db")
local app = require "app"
local respond_to = require("lapis.application").respond_to
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
 
app:match("/shorten", respond_to({
    POST = function(self)
        if self.params.key then
            local sel = db.select("username, apikey FROM users WHERE apikey = ?", self.params.key)
            print(dump(self.params))
        end
        
    end
}))
return app