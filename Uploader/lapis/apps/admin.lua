-- Made by Elperson
-- Admin module v1
-- https://github.com/Elpersonn/Raindrop
local lapis = require("lapis")
local db = require("lapis.db")
local app = require 'app'
local domains = require("domains")
local bcrypt = require("bcrypt")
local validate = require("lapis.validate")
local json_params = require("lapis.application").json_params
local util = require("lapis.util")
local respond_to = require("lapis.application").respond_to
local rounds = 10

local function checkValid(sess)
    local sel = db.select("* FROM sessions WHERE sessid = ?", sess or "none")
    if sel[1] and os.time() - sel[1].crstamp < 1800 then -- 1800 seconds = 30 minutes
        db.update("sessions", {
            crstamp = os.time()
        }, {
            sessid = sess
        })
        return true
    else
        db.delete("sessions", {sessid = sess or "none"})
        return false
    end
end
local function checkAdmin(sess)
    local sel = db.select("perms FROM users WHERE username IN ( SELECT sessfor FROM sessions WHERE sessid = ? )", sess)
    if sel[1] and sel[1].perms == "admin" then
        return true
    else
        return false
    end
end
--  and checkAdmin(self.session.USER)
app:match("/admin/getusers", respond_to({
    GET = function(self)
        local dbr = db.select("* FROM users")
        return { json = {dbres = dbr}}
    end,
}))
app:match("/admin", respond_to({
    GET = function(self)
        local sel = db.select("* FROM sessions WHERE sessid = ?", self.session.USER or "none")
        if sel[1] and os.time() - sel[1].crstamp < 1800 and checkAdmin(self.session.USER) then
            db.update("sessions", {
                crstamp = os.time()
            }, {
                sessid = self.session.USER
            })
            return { render = "admin", layout = "dark_layout" } 
        else
            db.delete("sessions", {sessid = self.session.USER or "a"})
            return { redirect_to = "/admin/login"}
        end
    end,


}))
app:match("/admin/login", respond_to({
    POST = json_params(function(self)
        if self.params.username and self.params.passwd then
            local dbr = db.select("* FROM USERS WHERE username = ?", self.params.username)
            if dbr[1] ~= nil and bcrypt.verify(self.params.passwd, dbr[1].passwd) then
                db.delete("sessions", "sessfor = ?", self.params.username)
                local sess = string.random(20)
                db.insert("sessions", {
                    sessid = sess;
                    crstamp = os.time();
                    sessfor = self.params.username
                })
                self.session.USER = sess
                return { status = 200 }
            else
                return { status = 401 }
            end
        else
            return { status = 400 }
        end


    end),
    GET = function(self)
        return { render = "admin_login", layout = false }
    end

}))
app:match("/admin/createuser", respond_to({
    POST = json_params(function(self)
        if self.params.username and self.params.passwd and self.params.accType and checkValid(self.session.USER) and checkAdmin(self.session.USER) then
            validate.assert_valid(self.params, {
                { "username", exists = true, min_length = 3, max_length = 30, matches_pattern = "^%w+$"};
                { "passwd", exists = true, min_length = 5};
                { "accType", exists = true, one_of = {"user", "admin"}}
            })
            local dbsel = db.select("1 FROM users WHERE username = ?", self.params.username)
            local T_apikey = string.random(20)
            if not dbsel[1] then
                db.insert("users", {
                username = self.params.username, 
                passwd = bcrypt.digest(self.params.passwd),
                apikey = T_apikey,
                perms = self.params.accType
                })
                return { status = 200, json = { accName = self.params.username, passwd = self.params.passwd, apikey = T_apikey}}
            else
                return {status = 409}
            end
        else
            return { status = 401, redirect_to = "/admin/login"}
        end
    end),
}))
app:match("/admin/deleteimg", respond_to({
    DELETE = json_params(function(self)
        
        if self.params.imgurl and checkValid(self.session.USER) and checkAdmin(self.session.USER) then
            local res = db.select("* FROM images WHERE imgurl = ?", self.params.imgurl)
            if res[1] then
                local adate = os.date("%A %x %X", res[1].upstamp)
                local uploader = res[1].uploader
                print(adate)
                assert(os.remove("/srv/lapis/html/files/"..self.params.imgurl))
                local res = db.delete("images", "imgurl = ?", self.params.imgurl)
                return { status = 200, json = { resp = "File "..self.params.imgurl.." has been successfully deleted.", meta = {author = "Uploaded by: "..uploader, date = "Uploaded On: "..adate}}}
            else return {status = 404}
            end
            
        else return {status = 401, redirect_to = "/admin/login"}    
        end
    end),
}))
app:match("/admin/deluser", respond_to({
    DELETE = json_params(function(self)
        if checkValid(self.session.USER) and self.params.username and checkAdmin(self.session.USER) then
            local res = db.delete("users", "username = ?", self.params.username)
            return { status = 200, json = {aff = res.affected_rows}}
        else
            return { status = 401, redirect_to = "/admin/login"} 
        end
    end)
}))
app:match("/admin/imginfo", respond_to({
    GET = json_params(function(self)
        if checkValid(self.session.USER) and self.params.imgurl and checkAdmin(self.session.USER) then
            local res = db.select("* FROM images WHERE imgurl = ?", self.params.imgurl)
            if res[1] then
                local adate = os.date("%A %d/%m/%Y %X", res[1].upstamp)
                local uploader = res[1].uploader
                return { status = 200, json = {author = "Uploaded by: ".. uploader, date = "Uploaded on: ".. adate}}
            else return { status = 404 }
            end
        else
            return { status = 401, redirect_to = "/admin/login" }
        end
    end),
}))
return app