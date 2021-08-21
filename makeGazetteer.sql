BEGIN TRANSACTION;
INSERT INTO gazetteer(pin_id,
                        final_text,
                        nation,
                        local_authority,
                        parish,
                        osgb_east,
                        osgb_north,
                        latitude,
                        longitude,
                        notes)
SELECT pin_id,
        final_text,
        nation,
        local_authority,
        parish,
        osgb_east,
        osgb_north,
        latitude,
        longitude,
        notes
FROM abridged_utf8;

DROP TABLE abridged_utf8;
COMMIT;
