# Made by Elperson
# Dockerfile. Do not modify unless you know what you're doing.
FROM mileschou/lapis
COPY . /srv
RUN ["chmod", "+x", "/srv/install.sh"]
RUN ["/srv/install.sh"]
RUN ["chmod", "+x", "/srv/start.sh"]
ENTRYPOINT ["/srv/start.sh"]
