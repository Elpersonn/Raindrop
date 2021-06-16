-- Made by Elperson
-- Shorten module v1
-- https://github.com/Elpersonn/Raindrop
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
        if self.params.key and self.params.url then
            local sel = db.select("username, apikey FROM users WHERE apikey = ?", self.params.key)
            if sel[1] then
                local shorturl = string.random(6)
                while db.select("origurl FROM shorturl WHERE origurl = ?", shorturl)[1] do
                    shorturl = string.random(6)
                end
                db.insert("shorturl", {
                    origurl = shorturl,
                    destination = self.params.url,
                    uploader = sel[1].username
                })
                if self.params.d or self.params.t then
                    return { layout = false, status = 200, json = { url = "https://elperson.pro/s/"..shorturl.."?t="..self.params.t.."&d="..self.params.d}}
                end
                return {layout = false, status = 200, json = { url = "https://elperson.pro/s/"..shorturl}}

            end
        end
        
    end
}))
app:get("/s/*", function(self)
    local sel = db.select("destination FROM shorturl WHERE origurl = ?", self.params.splat)
    if sel[1] then
        --print(self.req.headers["User-Agent"])
        if self.req.headers["User-Agent"] == [[Mozilla/5.0 (compatible; Discordbot/2.0; +https://discordapp.com)]] then
            if self.params.t or self.params.d then
                print("sus matches")
                return { render = "fakeredir", layout = false}
            else
                ngx.redirect(sel[1].destination, 302)
            end
        else
            ngx.redirect(sel[1].destination, 302)
        end
        
    else
        return { layout = "layout", render = "404", status = 404}
    end
end)
return app