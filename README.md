# Raindrop
V 0.1.5
Lua based ShareX uploader.
## Installation
1. Clone this / download this repository.
2. Modify docker-compose.yml
3. Modify Uploader/lapis/nginx.conf and change ```env DOMAIN=YOURDOMAINHERE.TLD```
4. Modify Uploader/lapis/domains.lua
5. Modify conf.lua and change the username and password to whatever you've put inside docker-compose.yml
6. Open terminal inside the repository directory.
7. ```docker-compose up```
