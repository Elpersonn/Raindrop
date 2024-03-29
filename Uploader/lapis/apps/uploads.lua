-- Made by Elperson
-- https://github.com/Elpersonn/Raindrop
local lapis = require("lapis")
local db = require("lapis.db")
local app = require "app"
local http = require("lapis.nginx.http")
local util = require("lapis.util")
local conf = require('lapis.config').get()
local respond_to = require("lapis.application").respond_to
--app.__base = app
local forceDownload = {"html", "php", "css", "js", "sh", "ttf", "otf", "exe", "htm", "7z"} -- At first I wanted this to forceDownload the files but now I decided to make it just not pass them at all.
local jsonmsg = {
	["embeds"] = {{
        ["title"] = "New upload",
        ["color"] = 16711680,
        ["url"] = "https://elperson.pro/",
        ["fields"] = {
			{["name"] = "Uploaded by", ["value"] = "%s"},
			{["name"] = "Uploaded on", ["value"] = "%s"}
		},
    }}
}

--[[local function dump(o)
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
 end]] -- IF YOU NEED TO DUMP A TABLE; REMOVE THIS COMMENT
 
local function checkWildcard(req)
	for i, v in pairs(domains.wildcard) do
		if v == req[2] .. "." .. req[3] then
			return true
		end
	end
	return false
end
local function checkDomain(domain)
	for i, v in pairs(domains.ndomains) do
		if v == domain[1] .. "." .. domain[2] then
			return true
		end
	end
	return false
end
function table.find(table, value)
	for i, v in pairs(table) do
		if v == value then
			return i
		end
	end
	return nil
end

app:match("/upload",
	respond_to({
			POST = function(self) -- TODO: Rewrite this partially
				if self.params.key ~= nil and self.params.file and self.params.domain then
					local sel = db.select("username, apikey, quota FROM users WHERE apikey = ?", self.params.key)
					local file = self.params.file
					local split = string.split(file.filename, ".")
					local filetype = split[#split]

					if sel[1] ~= nil and file and not table.find(forceDownload, filetype) then
						if sel[1].quota + #file.content > 104857600 then
								return { layout = false, status = 429, json = { error = "You are being rate-limited!"}}
							else
								db.update("users", {
									quota = sel[1].quota + #file.content,
									
								}, {
									apikey = sel[1].apikey
								})
							end
						local domains = require("domains")
						local splitdomain = string.split(self.params.domain, ".")
						local randomstr = string.random(6)
						local readfile = assert(io.open("/srv/lapis/html/files/" .. randomstr .. "." .. filetype, "w"))
						local checkimg = db.select("imgurl FROM images WHERE imgurl = ?", randomstr.."."..filetype)
						if checkimg[1] then
							while true do
								randomstr = http.simple("https://www.random.org/strings/?num=1&len=6&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new")
								local sel2 = db.select('imgurl FROM images WHERE imgurl = ?', randomstr.."."..filetype)
								if not sel2[1] then
									break
								end
							end
						end
						if #splitdomain == 3 and not checkWildcard(splitdomain) then
							return {layout = false, status = 400, json = {error = "Provided domain isn't a wildcard!"}}
						elseif #splitdomain == 2 and not checkDomain(splitdomain) then
							return {layout = false, status = 400, json = {error = "Provided domain doesn't exist!"}}
						elseif #splitdomain <= 1 or #splitdomain >= 4 then
							return {layout = false, status = 400, json = {error = "Bad request!"}}
						end
						if readfile then
							readfile:write(file.content)
							readfile:flush()
							readfile:close()
							local now = os.time()
							db.insert("images",
								{
									imgurl = randomstr .. "." .. filetype,
									uploader = sel[1].username,
									upstamp = now,
									lastvisited = now
								}
							)
							local embed2 = jsonmsg
								embed2.embeds[1].url = embed2.embeds[1].url..randomstr.."."..filetype
								embed2.embeds[1].fields[1].value = sel[1].username
								print(dump(embed2))
								embed2.embeds[1].fields[2].value = os.date("%A %d/%m/%Y %X", now)
								local a = http.simple({
									url = conf.uplog,
									method = "POST",
									headers = {
										["Content-Type"] = "application/json"
									},
									body = util.to_json(embed2)
		
								})
							if self.params.title or self.params.desc then
								if type(self.params.title) == "boolean" and self.params.title then self.params.title = "" end
								if type(self.params.desc) == "boolean" and self.params.desc then self.params.desc = "" end
								local title = util.escape(self.params.title or " ")
								local desc = util.escape(self.params.desc or " ")
								local color = self.params.color or " "
								return {
									layout = false,
									status = 201,
									json = {
										url = "https://" ..
											self.params.domain .. "/" .. randomstr .. "." .. filetype .. "?t=" .. title .. "&d=" .. desc.."&color="..color
									}
								}
							else
								return {
									layout = false,
									status = 201,
									json = {url = "https://" .. self.params.domain .. "/" .. randomstr .. "." .. filetype}
								}
							end
						end
					else
						return {layout = false, status = 415, json = {error = "Illegal file type / Bad API key"}}
					end
				else
					return {layout = false, status = 400, json = {error = "Illegal!"}}
				end
			end,
			GET = function(self)
				return "Raindrop 1.3.6"
			end
		}
	)
)
return app
