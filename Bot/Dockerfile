FROM node:lts-alpine3.13
COPY . /srv
RUN ["chmod", "a=rw", "/srv"]
RUN ["chmod", "+x", "/srv/install.sh"]
RUN ["sh", "/srv/install.sh"]
RUN ["chmod", "+x", "/srv/start.sh"]
ENTRYPOINT ["sh", "/srv/start.sh" ]
