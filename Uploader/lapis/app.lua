-- MADE BY ELPERSON IN POLAND
-- https://github.com/ElpersonPL/Raindrop
local lapis = require("lapis")
--local lfs = require("lfs")
local app = lapis.Application()
local db = require("lapis.db")
local bcrypt = require("bcrypt")
local bcryptrounds = 9
local mime = require("mime")
--app.layout = require("views.layout")

function app:include(module)
	package.loaded.app = self
	local subapp = require(module)
	if subapp ~= app then
	  if subapp.__base == nil then
		subapp.__base = subapp
	  end
	  self.__class.include(self, subapp, nil, self)
	end
end
  
app:enable("etlua")
app:include("apps.uploads")
app:get("/", function(self)
  return "Raindrop 0.1.3"
end)

local function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end
--[[local function findFile(filename)
	for file in lfs.dir("/srv/lapis/html/files") do
		if file == filename then
			return file
		end
	end 
end]] -- Keeping this for "later" if I ever need it.

app:get("/*", function(self)
    self.domain = os.getenv("DOMAIN")
	local filesplit = mysplit(self.params.splat, ".")
	local filetype = filesplit[#filesplit]
    local res = ngx.location.capture("/files/"..self.params.splat)
	if res.status then
	   if self.params.title or self.params.desc then
			self.title = self.params.title or self.params.splat
			self.desc = self.params.desc or self.params.splat
			self.type = mysplit(mime[filetype], "/")[1] 
			self.mime = mime[filetype]
			return { layout = false, render = "image" }
		
	   else
		ngx.exec("/files/"..self.params.splat)
	   end	
	else
		return { layout = "layout", render = "404", status = 404 }		
	end
end)

function app:handle_404()
	return { layout = "layout", render = "404", status = "404" }
end
return app
