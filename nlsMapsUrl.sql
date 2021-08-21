SELECT
pin_id,
'https://maps.nls.uk/geo/explore/#zoom=16&lat='
|| latitude
|| '&lon='
|| longitude
|| '-3.92568&layers=6&b=1&marker='
|| latitude
|| ','
|| longitude AS nlsMapUrl
FROM gazetteer
 WHERE lower(final_text) LIKE 'brae%';
 