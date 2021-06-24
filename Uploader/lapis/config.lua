-- config.lua
local config = require("lapis.config")

config("production", {
  	port = 8080,
  	session_name = "USER",
  	secret = "",
  	code_chache = "on",
	postgres = {
		host = "db",
		user = "admin",
		password = os.getenv('DBPASS'),
		database = "uploader"
	},
	uplog = ""
})
