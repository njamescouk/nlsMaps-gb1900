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
CREATE TABLE ngr (
pin_id      TEXT    PRIMARY KEY,
gridLetters TEXT,
gridE       INTEGER,
gridN       INTEGER);
CREATE TABLE nlsMapsUrl (
pin_id TEXT PRIMARY KEY, 
url TEXT);
CREATE INDEX gazXEN ON gazetteer (osgb_east, osgb_north);
CREATE INDEX gazXLAParish ON gazetteer (local_authority, parish);
CREATE INDEX gazXLatLong ON gazetteer (latitude, longitude);
CREATE INDEX gazXLongLat ON gazetteer (longitude, latitude);
CREATE INDEX gazXNE ON gazetteer (osgb_north, osgb_east);
CREATE INDEX ngrXletter ON NGR (gridLetters, pin_id);
CREATE INDEX ngrXEN ON NGR (gridE, gridN, pin_id);
CREATE INDEX ngrXNE ON NGR (gridN, gridE, pin_id);
CREATE VIEW nlsRow AS SELECT
pin_id,
local_authority,
parish,
latitude,
longitude,
'<tr><td><a href="'
|| url
|| '">'
|| final_text
|| '</a></td><td>'
|| parish
|| '</td><td>'
|| local_authority
|| '</td><td>'
|| gridLetters
|| printf('%05d', gridE)
|| printf('%05d', gridN)
|| '</td></tr>' AS row

FROM gazetteer 
JOIN nlsMapsUrl USING (pin_id)
JOIN ngr USING (pin_id)
/* nlsRow(pin_id,local_authority,parish,latitude,longitude,"row") */;
