 -- Made by Elperson
 -- SQL Setup file. Do not modify unless you know what you're doing.
CREATE TABLE IF NOT EXISTS invites (
    inviteid SERIAL NOT NULL,
    invite TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS users (
    userid SERIAL NOT NULL,
    username TEXT NOT NULL,
    passwd TEXT NOT NULL,
    apikey TEXT NOT NULL,
    perms TEXT NOT NULL,
    PRIMARY KEY (userid)
);
CREATE TABLE IF NOT EXISTS sessions
(
    sessid text NOT NULL,
    crstamp bigint NOT NULL,
    sessfor text NOT NULL
);
CREATE TABLE IF NOT EXISTS images (
    imgurl TEXT NOT NULL,
    uploader TEXT NOT NULL,
    upstamp BIGINT NOT NULL,
    PRIMARY KEY (imgurl)
);
CREATE TABLE IF NOT EXISTS shorturl (
    origurl TEXT NOT NULL,
    destination TEXT NOT NULL,
    uploader TEXT NOT NULL,
    PRIMARY KEY (origurl)
);
ALTER SEQUENCE users_userid_seq
    MINVALUE 0
    START WITH 0
    RESTART WITH 0;