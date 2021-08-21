WITH info as (
SELECT 
json_object('text', 
'<a href="'
|| url
|| '">'
|| final_text
|| '</a><br>'
|| gridLetters
|| printf('%05d', gridE)
|| printf('%05d', gridN)
|| ',',
'lat',
latitude,
'long'
,longitude)
 AS urlObj
FROM gazetteer
JOIN
ngr USING (pin_id)
JOIN nlsMapsUrl USING (pin_id)
WHERE lower(final_text) LIKE '%library%'
)
SELECT 'var gbMash =[
'
|| group_concat(urlObj, ',
')
|| '
];' AS array FROM info;
