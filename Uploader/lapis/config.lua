-- config.lua
local config = require("lapis.config")

config("production", {
  port = 8080,
  session_name = "USER",
  secret = "w;dlkf8nt34in39nntv89",
  code_chache = "on",
	postgres = {
		host = "db",
		user = "admin",
		password = "Pj+5K]hDT:FT>(8.",
		database = "uploader"
	}
})
