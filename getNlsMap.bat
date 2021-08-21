@echo off
rem 
echo SELECT row FROM nlsRow WHERE pin_id IN >tmp.sql
echo (SELECT pin_id FROM gazetteer>>tmp.sql
echo WHERE lower(final_text) LIKE ('%%' ^|^| lower('%*') ^|^| '%%'))>>tmp.sql
echo ORDER BY local_authority, parish, latitude DESC, longitude;>>tmp.sql
chcp 65001 > nul
sqlite3 gb1900.db < tmp.sql > tmp.table
call tablewrap tmp.table > nlsLinks.html

del tmp.sql > nul
del tmp.table > nul
