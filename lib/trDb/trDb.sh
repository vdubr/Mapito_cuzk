#$1 - cislo KU,$2 - souradnicovy system, $3 - DB name, $4 - DB user, $5 - DB password
#muze nastat problem
# ERROR 6: Unable to load PROJ.4 library (libproj.so), creation of OGRCoordinateTransformation failed 
# reseni
# sudo ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so

time=$(date +%s)

cd data
#mkdir $TIME_"$2"_"$1"
#cd $TIME_"$2"_"$1"

mkdir $time"_"$2"_"$1
cd $time"_"$2"_"$1

wget services.cuzk.cz/gml/inspire/cp/epsg%2D"$2"/$1.zip
unzip $1.zip

for x in CZ CP CB
do xsltproc -o "$x"_"$1".gml ../../$x.xsl $1.xml 

#ogr2ogr -f "PostgreSQL" PG:"host=localhost user="$4" dbname="$3" password="$5"" "$x"_"$1".gml -nlt MULTIPOLYGON -nln "$1"_"$x" -s_srs "epsg:102067" -t_srs "epsg:4326"


done

ogr2ogr -f "PostgreSQL" PG:"host=localhost user="$4" dbname="$3" password="$5"" "CP"_"$1".gml -nlt MULTIPOLYGON -nln "$1"_"CP" -s_srs "epsg:4258" -t_srs "epsg:4326" -skipfailures 
ogr2ogr -f "PostgreSQL" PG:"host=localhost user="$4" dbname="$3" password="$5"" "CB"_"$1".gml -nlt LINESTRING -nln "$1"_"CB" -s_srs "epsg:4258" -t_srs "epsg:4326" -skipfailures 
ogr2ogr -f "PostgreSQL" PG:"host=localhost user="$4" dbname="$3" password="$5"" "CZ"_"$1".gml -nlt POLYGON -nln "$1"_"CZ" -s_srs "epsg:4258" -t_srs "epsg:4326" -skipfailures 


echo "konec"
cd ../..

#rm -rf *
#cd ..
#rm -r "$2"_"$1"


