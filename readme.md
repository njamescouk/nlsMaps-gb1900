# Extending GB1900

## Acknowledgment

The GB1900 Gazetteer (Abridged) is made available by the 
GB1900 Project - the Great Britain Historical GIS Project at 
the University of Portsmouth, the GB1900 partners and volunteers.

## Motivation

Whilst reading up on Yorkshire's geology I came across a reference to a 
Tinkers Hill, which I eventually found thanks to the GB1900 project.

I've done some work to make this easier (for me, at least) to use; 
read on for more.

## Extension

The big idea is to put the GB1900 data, supplied as csv, into a 
database and provide a reasonably straightforward way of extracting 
place names and locations. The end result is an 
[sqlite](https://sqlite.org/index.html) 
database taking up about .75Gb of storage. I can't host that
so what follows is a recipie to recreate the database from the 
`gb1900_abridged.csv` file downloaded in a zip file from 
[the GB1900](https://www.visionofbritain.org.uk/data/) site. This 
also helps if you want to replicate or improve on what I've done.

I'm on windows 7, but I have some of [MSYS](https://www.msys2.org/) installed 
so the method should translate to linux easily enough, but 
may be problematic on a raw windows installation. You'll need
[sqlite3](https://sqlite.org/download.html) to do 
the database management.

The first problem is _extracting the csv file_. This fails on windows 7
when using explorer, ultimate zip and 7z. The windows 10 file manager 
extracts it with no problem. I don't what other methods there are.

## Conversion to Database
Having extracted files from the zip to the src directory, create 
the database and tables (what follows is wrapped up in 
[`createGB1900Db.bat`](createGB1900Db.bat)):

    sqlite3 gb1900.db < createTables.sql
	
`gb1900_abridged.csv` is encoded as UTF-16LE. We need to convert this to UTF-8, either do

    iconv -f UTF-16LE -t UTF-8 src\gb1900_abridged.csv > abridged_utf8.csv

or open `gb1900_abridged.csv` in a modern text editor and save as 
`abridged_utf8.csv` with encoding UTF-8.

Import into `gb1900.db` with and use makeGazetteer.sql to transfer data into a table with properly
typed geo coordinates.

    sqlite3 -csv gb1900.db ".import abridged_utf8.csv abridged_utf8"
    sqlite3 -csv %GB_DB% < makeGazetteer.sql

This takes some time.

This table has locations expressed as latitude-longitude and as absolute 
Ordnance Survey grid references. It's handy to have grid references with 
the letter codes for 100 Km squares, these commands (along with supplied 
csv and sql files) create a table called `ngr`, which has columns `pin_id,
gridLetters,gridE,gridN` with grid references at 1 metre resolution.

Comments in [`populateNGR.sql`](populateNGR.sql) give the gory details

    rem sqlite3 .import doesn't recognise column types
    sqliteimport %GB_DB% easting100KSquares.csv
    sqliteimport %GB_DB% easting500KSquares.csv
    sqliteimport %GB_DB% northing100KSquares.csv
    sqliteimport %GB_DB% northing500KSquares.csv
    echo populating ngr table
    sqlite3 gb1900.db < populateNGR.sql
    sqlite3 %GB_DB% "DROP TABLE easting100KSquares; DROP TABLE easting500KSquares; DROP TABLE northing100KSquares; DROP TABLE northing500KSquares; 

This takes some time.

It's handy to have pre recorded links to the  6"
ordnance survey maps at the [National Library of Scotland](https://maps.nls.uk/)

    sqlite3 %GB_DB% < makeNlsUrl.sql

Index the tables

    sqlite3 %GB_DB% "CREATE INDEX gazXEN ON gazetteer (osgb_east, osgb_north);"
    sqlite3 %GB_DB% "CREATE INDEX gazXLAParish ON gazetteer (local_authority, parish);"
    sqlite3 %GB_DB% "CREATE INDEX gazXLatLong ON gazetteer (latitude, longitude);"
    sqlite3 %GB_DB% "CREATE INDEX gazXLongLat ON gazetteer (longitude, latitude);"
    sqlite3 %GB_DB% "CREATE INDEX gazXNE ON gazetteer (osgb_north, osgb_east);"
    sqlite3 %GB_DB% "CREATE INDEX ngrXletter ON ngr (gridLetters, pin_id);"
    sqlite3 %GB_DB% "CREATE INDEX ngrXEN ON ngr (gridE, gridN, pin_id);"
    sqlite3 %GB_DB% "CREATE INDEX ngrXNE ON ngr (gridN, gridE, pin_id);"
	
## Extracting Data

For the time being I've cooked up some batch files to query the database. These merely 
make it possible to look for substrings of `final text`, but emit the results 
in different formats.

+  getPlace.bat

   gives `final_text, parish, local authority, gridRef` straight to screen, eg
    
    <pre>
    $ getPlace.bat waifs
    sought: waifs
    place                                parish                     LA          gridRef
    -----------------------------------  -------------------------  ----------  --------------
    Home for Waifs & Strays              Nidd                       Harrogate   SE 30541 59830
    Beckett Home (Waifs & Strays)        Leeds (Un-parished)        Leeds       SE 28406 37473
    St. Chad's Home (Waifs & Strays)     Leeds (Un-parished)        Leeds       SE 27581 37104
    Rose Cottage (Home for Waifs & Stra  Dickleburgh And Rushall    South Norf  TM 16581 82264
    Industrial Home (Waifs & Strays)     Walsham-Le-Willows         Mid Suffol  TL 99704 71245
    Bognor Boys' Home (Waifs & Strays)   Bognor Regis               Arun        SU 92781 00059
    </pre>

+  getNlsMap.bat

   writes to the file [nlsLinks.html](example/nlsLinks.html) which has links to the 
   location of `final_text` at the 
   [National Library of Scotland](https://maps.nls.uk/) along with 
   `parish, local_local_authority, gridRef`.
   
   Should you wish to know about drainage of Romney Marsh, try 
   `getNlsMap.bat petty sewer`.
     
+ getMash.bat

   This is a failed attempt to use the [NLS Maps Api](https://maps.nls.uk/projects/api/) 
   with leaflet.
   
   Everything's hard coded as this is just a preliminary hack.
   sqlite3 writes a javascript variable containing marker data in `mash.js` 

   `mash.js` is referenced by mashup.html. Four attempts at using laflet
   to write some bits of html into a web page have failed, presumably because 
   of an error imperceptible to the human eye. Such is javascript.

   However the markers usually appear, in a browser dependent fashion, but that's your lot.

+ river Thames
  
   In a similar vein `sqlite3 gb1900.db < riverThames.sql` produces 
   [riverThames.html](example/riverThames.html) with a rather more sophisticated
   query.

## Further Work

Obviously a lot more could be done. For my purposes for the time
being, it's done. Should you wish to take it further be my guest,
if you have any queries contact me via githhub.
