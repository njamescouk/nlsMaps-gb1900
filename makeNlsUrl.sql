BEGIN TRANSACTION;
INSERT INTO nlsMapsUrl (pin_id, url)
SELECT
pin_id,
'https://maps.nls.uk/geo/explore/#zoom=16&lat='
|| latitude
|| '&lon='
|| longitude
|| '-3.92568&layers=6&b=1&marker='
|| latitude
|| ','
|| longitude AS url
FROM gazetteer;
COMMIT;
