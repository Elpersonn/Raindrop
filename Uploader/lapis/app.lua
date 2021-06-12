-- MADE BY ELPERSON IN POLAND
-- https://github.com/Elpersonn/Raindrop
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
local charset = {}


-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48, 57 do
	table.insert(charset, string.char(i))
end
for i = 65, 90 do
	table.insert(charset, string.char(i))
end
for i = 97, 122 do
	table.insert(charset, string.char(i))
end

function string.random(length)
	math.randomseed(os.time())

	if length > 0 then
		return string.random(length - 1) .. charset[math.random(1, #charset)]
	else
		return ""
	end
end
  
app:enable("etlua")
app:include("apps.uploads")
app:include("apps.admin")
app:include("apps.shorten")
app:include("apps.signup")
app:get("/", function(self)
    	ngx.redirect("https://shoppy.gg/product/WBAO8BR")
end)

function string.split (inputstr, sep)
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
	local filesplit = string.split(self.params.splat, ".")
	local filetype = filesplit[#filesplit]
    local res = ngx.location.capture("/files/"..self.params.splat)
	print(res.status)
	if res.status then
	   if self.params.title or self.params.desc then
			self.title = self.params.title or self.params.splat
			self.desc = self.params.desc or self.params.splat
			self.type = string.split(mime[filetype], "/")[1] 
			self.mime = mime[filetype]
			return { layout = false, render = "image" }
		else
			ngx.exec('/files/'..self.params.splat)
		end
	end
end)
app:get("/domains", function(self)
	local domains = require('domains')
	self.dom = ""
	self.wdom = ""
	for i,v in pairs(domains.ndomains) do
		self.dom = self.dom..", "..v
	end
	for i,v in pairs(domains.wildcard) do
		self.wdom = self.wdom.." "..v
	end
	return { layout = "dark_layout", render = "domains"}
end)
function app:handle_404()
	return { layout = "layout", render = "404", status = 404 }
end
return app
