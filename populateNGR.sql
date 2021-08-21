BEGIN TRANSACTION;
/*
    # note on osgb grid letters
    
    500 Km squares specified by 1st letter of GR:
        
     1500 -|-----|-----|
           |  H  |  J  |
     1000 -|-----|-----|
           |  N  |  O  |
      500 -|-----|-----|
           |  S  |  T  |
        0 -|-----|-----|
       N/E 0     500   1000
        
    first letter:

    set(0N)    = {S,T}
    set(500N)  = {N,O}
    set(1000N) = {H,J}
    set(0E)    = {H,N,S}
    set(500E)  = {J,O,T}


    eg easting in [0,500) and northing in [500, 1000)
    letter = set(0E) intersect set(500N) = {N}

    within 500Km squares, 100 Km sq specified by 2nd letter of GR

    500 |---|---|---|---|---|
        | A | B | C | D | E |
    400 |---|---|---|---|---|
        | F | G | H | J | K |
    300 |---|---|---|---|---|
        | L | M | N | O | P |
    200 |---|---|---|---|---|
        | Q | R | S | T | U |
    100 |---|---|---|---|---|
        | V | W | X | Y | Z |
      0 |---|---|---|---|---|
        0   100 200 300 400 500

    set(0N)    = {A,F,L,Q,V}
    ...
    set(0E)    = {V,W,X,Y,Z}
    ...

    eg easting in [100,200) and northing in [200, 300)
    letter = set(100E) intersect set(200N) = {M}

    NOTE: THIS REALLY SCREWS UP unless limits in northing/easting*KSquares 
    tables are numbers. sqlite3 .import command will import these as text
    which is why we use sqliteimport to produce the tables in createGB1900Db.bat.
    sqliteimport barfs when confronted with lots of data, so we have a 
    fandango when importing the the abridged csv file
*/

/*
    insert into these fields of ngr
*/
INSERT INTO ngr (
pin_id,
gridLetters,
gridE,
gridN)
/*
    first get hold of grid refs as integers
    along with position in 500Km square
    
    we're working in integral metres throughout
*/
WITH metres AS (
  SELECT pin_id,
         round(osgb_east) AS easting,
         round(osgb_north) AS northing,
         round(osgb_east) % 500000 AS e500,
         round(osgb_north) % 500000 AS n500
FROM gazetteer
) 
SELECT 
/*
    this is really a foreign key
*/
pin_id,
/*
    concatenate first and second grid letters
*/
(
    /*
        first letter is intersection of easting and northern sets
        of possible letters
    */
    SELECT letter
    /*
        given easting in metres, find set of possible 500Km letters
        ie. those letters with easting between upper and lower bounds
    */
    FROM easting500KSquares
    WHERE metres.easting >= loLimit AND metres.easting < (loLimit + 500000)
    INTERSECT
    /*
        northing likewise
    */
    SELECT letter
    FROM northing500KSquares
    WHERE metres.northing >= loLimit AND metres.northing < (loLimit + 500000)
) 
|| 
(
    /*
        second letter is intersection of easting and northern sets
        of possible letters
    */
    SELECT letter
    /*
        given easting in 100Km square in metres, find set of possible 
        500Km letters ie. those letters with easting between upper 
        and lower bounds
    */
    FROM easting100KSquares
    WHERE metres.e500 >= loLimit AND metres.e500 < (loLimit + 100000)
    INTERSECT
    SELECT letter
    /*
        northing likewise
    */
    FROM northing100KSquares
    WHERE metres.n500 >= loLimit AND metres.n500 < (loLimit + 100000)
) 
AS gridLetters,
/*
    position in 100Km square is remainder after dividing
    position in 500Km square by 100Km
*/
e500 % 100000 AS gridE,
n500 % 100000 AS gridN
FROM metres
ORDER BY gridLetters, gridE, gridN; 
COMMIT;
