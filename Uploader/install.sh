#!/bin/bash
# Made by Elperson
# System setup file. Do not modify unless you know what you're doing.
apt update
apt install -y make --fix-missing
apt install -y nano --fix-missing
apt install -y luarocks --fix-missing
luarocks install bcrypt
luarocks install lapis # Updating the lapis version.
luarocks install lua-resty-mail
mkdir -p /srv/lapis/html/files # This doesn't work I think... ?
chmod a=rw /srv/lapis/html/files
