.output 'riverThames.js'

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
 WHERE (
 lower(final_text) LIKE ('%%' || lower('stairs') || '%%')
 OR lower(final_text) LIKE ('%%' || lower('landing%stage') || '%%')
 OR lower(final_text) LIKE ('%%' || lower('pier') || '%%')
 OR lower(final_text) LIKE ('%%' || lower('jetty') || '%%')
 OR lower(final_text) LIKE ('%%' || lower('wharf') || '%%')
 )
 AND local_authority IN ('City of London','Tower Hamlets','Southwark','Westminster','Lambeth')
)
SELECT 'var gbMash =[
'
|| group_concat(urlObj, ',
')
|| '
];' AS array FROM info;
