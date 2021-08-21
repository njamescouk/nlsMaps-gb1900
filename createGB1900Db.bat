@echo off
rem 
set GB19_SRC_FILE=src\gb1900_abridged.csv
set GB_DB=gb1900.db
if not exist %GB19_SRC_FILE% goto usage
if exist %GB_DB% goto dbexist
rem if exist %GB_DB% goto usage
where /q sqlite3
if not %ERRORLEVEL%==0 then goto nosqlite3

sqlite3 gb1900.db < createTables.sql
echo converting to UTF-8
iconv -f UTF-16LE -t UTF-8 %GB19_SRC_FILE% > abridged_utf8.csv
echo making gazetteer table
rem sqliteimport chokes on big files
sqlite3 -csv %GB_DB% ".import abridged_utf8.csv abridged_utf8"
sqlite3 -csv %GB_DB% < makeGazetteer.sql
rem sqlite3 .import doesn't recognise column types
sqliteimport %GB_DB% easting100KSquares.csv
sqliteimport %GB_DB% easting500KSquares.csv
sqliteimport %GB_DB% northing100KSquares.csv
sqliteimport %GB_DB% northing500KSquares.csv
echo populating ngr table
sqlite3 gb1900.db < populateNGR.sql
sqlite3 %GB_DB% "DROP TABLE easting100KSquares; DROP TABLE easting500KSquares; DROP TABLE northing100KSquares; DROP TABLE northing500KSquares; 
echo populating nls url table
sqlite3 %GB_DB% < makeNlsUrl.sql
echo indexing
sqlite3 %GB_DB% "CREATE INDEX gazXEN ON gazetteer (osgb_east, osgb_north);"
sqlite3 %GB_DB% "CREATE INDEX gazXLAParish ON gazetteer (local_authority, parish);"
sqlite3 %GB_DB% "CREATE INDEX gazXLatLong ON gazetteer (latitude, longitude);"
sqlite3 %GB_DB% "CREATE INDEX gazXLongLat ON gazetteer (longitude, latitude);"
sqlite3 %GB_DB% "CREATE INDEX gazXNE ON gazetteer (osgb_north, osgb_east);"
sqlite3 %GB_DB% "CREATE INDEX ngrXletter ON ngr (gridLetters, pin_id);"
sqlite3 %GB_DB% "CREATE INDEX ngrXEN ON ngr (gridE, gridN, pin_id);"
sqlite3 %GB_DB% "CREATE INDEX ngrXNE ON ngr (gridN, gridE, pin_id);"
goto end

:usage
echo you need to have %GB19_SRC_FILE% from https://www.visionofbritain.org.uk/data/
echo download GB1900_gazetteer_abridged_july_2018.zip and extract to src directory
goto end

:dbexist
echo %GB_DB% already exists, delete it and try again if you want to proceed
goto end

:nosqlite3
echo can't find sqlite3.exe
goto end

:end
