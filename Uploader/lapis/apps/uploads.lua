-- Made by Elperson
-- https://github.com/Elpersonn/Raindrop
local lapis = require("lapis")
local db = require("lapis.db")
local app = require "app"

local util = require("lapis.util")
local respond_to = require("lapis.application").respond_to
--app.__base = app
local forceDownload = {"html", "php", "css", "js", "sh", "ttf", "otf", "exe", "htm"} -- At first I wanted this to forceDownload the files but now I decided to make it just not pass them at all.

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

app:match(
	"/upload",
	respond_to(
		{
			POST = function(self) -- TODO: Rewrite this partially
				if self.params.key ~= nil and self.params.file and self.params.domain then
					local sel = db.select("username, apikey FROM users WHERE apikey = ?", self.params.key)
					local file = self.params.file
					local split = string.split(file.filename, ".")
					local filetype = split[#split]

					if sel[1] ~= nil and file and not table.find(forceDownload, filetype) then
						local domains = require("domains")
						local splitdomain = string.split(self.params.domain, ".")
						local randomstr = string.random(6)
						local readfile = assert(io.open("/srv/lapis/html/files/" .. randomstr .. "." .. filetype, "w"))

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
							db.insert(
								"images",
								{
									imgurl = randomstr .. "." .. filetype,
									uploader = sel[1].username,
									upstamp = os.time()
								}
							)
							if self.params.title or self.params.desc then
								if type(self.params.title) == "boolean" and self.params.title then self.params.title = "" end
								if type(self.params.desc) == "boolean" and self.params.desc then self.params.desc = "" end
								local title = util.escape(self.params.title or " ")
								local desc = util.escape(self.params.desc or " ")
								return {
									layout = false,
									status = 200,
									json = {
										url = "https://" ..
											self.params.domain .. "/" .. randomstr .. "." .. filetype .. "?title=" .. title .. "&desc=" .. desc
									}
								}
							else
								return {
									layout = false,
									status = 200,
									json = {url = "https://" .. self.params.domain .. "/" .. randomstr .. "." .. filetype}
								}
							end
						end
					else
						return {layout = false, status = 400, json = {error = "File missing / Illegal file type"}}
					end
				else
					return {layout = false, status = 400, json = {error = "Illegal!"}}
				end
			end,
			GET = function(self)
				return "Raindrop 1.1.6b"
			end
		}
	)
)
return app
