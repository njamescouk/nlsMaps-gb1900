@echo off

echo .width 35 25> tmp.sql
echo SELECT >> tmp.sql
echo final_text AS place>> tmp.sql
echo ,parish>> tmp.sql
echo ,local_authority AS LA,>> tmp.sql
echo gridLetters ^|^| ' ' ^|^| printf('%%05d', gridE) ^|^| ' ' ^|^| printf('%%05d', gridN) AS gridRef >> tmp.sql
rem echo ,CAST (osgb_east AS INTEGER) ^|^| ',' ^|^| CAST(osgb_north AS INTEGER) AS absGridRef >> tmp.sql
rem echo ,latitude>> tmp.sql
rem echo ,longitude>> tmp.sql
echo FROM gazetteer JOIN ngr USING (pin_id)>> tmp.sql
echo WHERE lower(final_text) LIKE ('%%' ^|^| lower('%*') ^|^| '%%')>> tmp.sql
echo ORDER BY latitude DESC, longitude;>> tmp.sql

chcp 65001 > nul
sqlite3 :memory: "SELECT 'sought: ' || lower('%*');"
sqlite3 -header -column gb1900.db < tmp.sql

del tmp.sql > nul
