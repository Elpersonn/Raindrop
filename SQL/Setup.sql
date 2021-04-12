 -- Made by Elperson
 -- SQL Setup file. Do not modify unless you know what you're doing.
CREATE TABLE IF NOT EXISTS users (
    userid SERIAL,
    username TEXT,
    passwd TEXT,
    apikey TEXT,
    PRIMARY KEY (userid)
);
ALTER SEQUENCE users_userid_seq
    MINVALUE 0
    START WITH 0
    MAXVALUE 10000 -- You can modify this go ahead.
    RESTART WITH 0;

