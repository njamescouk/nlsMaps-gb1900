DROP TABLE IF EXISTS gazetteer;
CREATE TABLE gazetteer (pin_id          TEXT,
                        final_text      TEXT,
                        nation          TEXT,
                        local_authority TEXT,
                        parish          TEXT,
                        osgb_east       REAL,
                        osgb_north      REAL,
                        latitude        REAL,
                        longitude       REAL,
                        notes           TEXT);

DROP TABLE IF EXISTS ngr;
CREATE TABLE ngr (
pin_id      TEXT    PRIMARY KEY,
gridLetters TEXT,
gridE       INTEGER,
gridN       INTEGER);

DROP TABLE IF EXISTS nlsMapsUrl;
CREATE TABLE nlsMapsUrl (
pin_id TEXT PRIMARY KEY, 
url TEXT);
