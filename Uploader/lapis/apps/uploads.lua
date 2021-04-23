
-- Made by Elperson
-- https://github.com/Elpersonn/Raindrop
local lapis = require("lapis")
local db = require("lapis.db")
local app = require 'app'
local domains = require("domains")
local util = require("lapis.util")
local respond_to = require("lapis.application").respond_to
--app.__base = app
local charset = {}
local forceDownload = {"html", "php", "css", "js", "sh", "ttf", "otf", "exe"} -- At first I wanted this to forceDownload the files but now I decided to make it just not pass them at all.

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

local function  checkWildcard(req)
	
	for i,v in pairs(domains.wildcard) do
		if v == req[2].."."..req[3] then
			return true
		end
	end
	return false
end
local function checkDomain(domain)
	for i,v in pairs(domains) do
		if v == domain[1].."."..domain[2] then
			return true
		end
	end
	return false
end
function table.find(table, value)
	for i,v in pairs(table) do
		if v == value then
			return i
		end
	end
	return nil
end
function string.random(length)
  math.randomseed(os.time())

  if length > 0 then
    return string.random(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end
local function mysplit (inputstr, sep) -- I should put this split function into a module script.
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

app:match("/upload", respond_to({
    POST = function(self)
        if self.params.key ~= nil and self.params.file and self.params.domain then
            local sel = db.select("apikey FROM users WHERE apikey = ?", self.params.key)
        local file = self.params.file
	    local split = mysplit(file.filename, ".")
	    local filetype = split[#split] 

	   if sel[1] ~= nil and file and not table.find(forceDownload, filetype) then
		local splitdomain = mysplit(self.params.domain, ".")
		local randomstr = string.random(6)
		local readfile = assert(io.open("/srv/lapis/html/files/"..randomstr.."."..filetype, "w"))
		print(#splitdomain)
		if #splitdomain == 3 and not checkWildcard(splitdomain) then
			 return { layout = false, status = 400, json = { error = "Provided domain isn't a wildcard!"}}
		elseif #splitdomain == 2 and not checkDomain(splitdomain) then
			return { layout = false, status = 400, json = { error = "Provided domain doesn't exist!" }}
		end
		if readfile then
            readfile:write(file.content)
            readfile:flush()
            readfile:close()
            if self.params.title or self.params.desc then
				local title = util.escape(self.params.title) or nil
				local desc = util.escape(self.params.desc) or nil
					return { layout = false, status = 200,  json = { url = "http://"..self.params.domain.."/"..randomstr.."."..filetype.."?title="..title.."&desc="..desc }}
			else	
				return { layout = false, status = 200,  json = { url = "http://"..self.params.domain.."/"..randomstr.."."..filetype }}
			end
		end
            else
		return { layout = false, status = "400", json = { error = "File missing / Illegal file type"}} 
	    end
         else
		return { layout = false, status = 401, json = { error = "Unauthorized" }}
	 end
    end,
    GET = function(self)
        return "Raindrop 0.1.6"
    end

}))
return app
