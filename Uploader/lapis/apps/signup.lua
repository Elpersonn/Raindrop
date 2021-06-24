-- Made by Elperson
-- Signup module v1
-- https://github.com/Elpersonn/Raindrop
local lapis = require("lapis")
local db = require("lapis.db")
local app = require "app"
local validate = require("lapis.validate")
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local http = require("lapis.nginx.http")
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
    username = "",
    password = "",
  })
local mailmsg = "Thank you for activating your raindrop account.\n You may upload pictures using these credentials\nAPI KEY: %s\n PASSWORD: %s"
local rounds = 10
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
            local sel = db.select("username FROM users WHERE username = ?", self.params.username)
            if sel[1] then
                return { status = 409, json = { error = "Username taken" }}
            end
            local rgen = string.split(http.simple("https://www.random.org/strings/?num=2&len=20&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new"), "\n")
            local password = rgen[2]..string.random(5)
            local akey = rgen[1]
            db.delete("invites", { invite = self.params.invite })
            db.insert("users", {
                username = self.params.username,
                apikey = akey,
                passwd = bcrypt.digest(password, rounds),
                perms = 1
            })
            --message.body = string.format(message.body, akey, password)
            --message.headers.to = string.format(message.headers.to, self.params.email)
            --[[local k, e = smtp.send{
                from = "",
                rcpt = self.params.email,
                user = "",
                password = "",
                port = 465,
                server = "smtp.gmail.com",
                source = smtp.message(message),
                create = sslCreate
            }
            if not k then
                return { status = 500, json = { error = e}}
            end]]
            local formmail = string.format(mailmsg, akey, password)
            local ok, err = mailer:send({
                from = "Raindrop Uploader",
                to = { self.params.email },
                subject = "Raindrop account activation",
                text = formmail
            })
            if not ok then print(err) end
            return { status = 201, json = { msg = "Check your inbox!"}}
        else
            return { status = 400}
        end
    end)
}))
return app