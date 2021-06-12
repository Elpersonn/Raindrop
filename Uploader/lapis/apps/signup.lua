local lapis = require("lapis")
local db = require("lapis.db")
local app = require "app"
local validate = require("lapis.validate")
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local bcrypt = require("bcrypt")
--[[local smtp = require("socket.smtp")
local ssl = require('ssl')
local https = require 'ssl.https'
local mime = require("mime")]]
local mail = require('resty.mail')
local mailer, err = mail.new({
    host = "smtp.gmail.com",
    port = 587,
    starttls = true,
    username = "raindrop.uploader@gmail.com",
    password = "ynvc9W7mrG4YYLd",
  })
local mailmsg = "Thank you for activating your raindrop account.\n You may upload pictures using these credentials\nAPI KEY: %s\n PASSWORD: %s"
local rounds = 10
--[[local message = {
    headers = {
        subject = "Raindrop account activation",
        to = "%s",
        from = "raindrop.uploader@gmail.com"
    },
    body = "Thank you for activating your raindrop account.\n You may upload pictures using these credentials\nAPI KEY: %s\n PASSWORD: %s"
}]]
--[[function sslCreate()
    local sock = socket.tcp()
    return setmetatable({
        connect = function(_, host, port)
            local r, e = sock:connect(host, port)
            if not r then return r, e end
            sock = ssl.wrap(sock, {mode='client', protocol='tlsv1'})
            return sock:dohandshake()
        end
    }, {
        __index = function(t,n)
            return function(_, ...)
                return sock[n](sock, ...)
            end
        end
    })
end]]
app:match("/signup", respond_to({
    GET = function(self)
        return {layout = "dark_layout", render = "signup"}
    end,
    POST = json_params(function(self)
        validate.assert_valid(self.params, {
            { "username", exists = true, min_length = 3, max_length = 25,  matches_pattern="^%w+$"},
            { "invite", exists = true, min_length = 25,  max_length = 25, matches_pattern = "^INVT%-%w+$"},
            { "email", exists = true, min_length = 3}
        })
        local res = db.select("invite FROM invites WHERE invite = ?", self.params.invite)
        if res[1] then 
            local password = string.random(25)
            local akey = string.random(20)
            db.delete("invites", { invite = self.params.invite })
            db.insert("users", {
                username = self.params.username,
                apikey = akey,
                passwd = bcrypt.digest(password, rounds)
            })
            --message.body = string.format(message.body, akey, password)
            --message.headers.to = string.format(message.headers.to, self.params.email)
            --[[local k, e = smtp.send{
                from = "raindrop.uploader@gmail.com",
                rcpt = self.params.email,
                user = "raindrop.uploader@gmail.com",
                password = "ynvc9W7mrG4YYLd",
                port = 465,
                server = "smtp.gmail.com",
                source = smtp.message(message),
                create = sslCreate
            }
            if not k then
                return { status = 500, json = { error = e}}
            end]]
            local a = string.format(mailmsg, akey, password)
            local ok, err = mailer:send({
                from = "Raindrop Uploader",
                to = { self.params.email },
                subject = "Raindrop account activation",
                text = a
            })
            if not ok then print(err) end
        else
            return { status = 400}
        end
    end)
}))
return app