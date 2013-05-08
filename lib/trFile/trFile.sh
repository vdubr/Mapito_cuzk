#$ku - cislo KU, $isrs - souradnicovy system(vstupni),$osrs - souradnicovy system(vystupni), $format - format
# sh trSHP.sh 624578 4258 4326 shp

#sudo chmod 777 data

#muze nastat problem
# ERROR 6: Unable to load PROJ.4 library (libproj.so), creation of OGRCoordinateTransformation failed 
# reseni
# sudo ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so
# sudo apt-get install zip

# sh trFile.sh 715174 5514 4326 shp

#otestovany formaty kml,gml,shp (vse ok),
#u shp probehle preklah &amp; behem generovani shp
#u ostatních formátů dojde k nahrade retezce amp; za nic

#na vstupu otestovano 5514,

#na vystupu otestovano 4326,


ku=$1
isrs=$2 #parametr v "" aby byl str
osrs=$3 #parametr v "" aby byl str
pathosrs=$3
format=$4
time=$5

cd ../../data
#mkdir $time"_"$ku"_"$osrs"_"$format
cd $time"_"$ku"_"$osrs"_"$format

wget "services.cuzk.cz/gml/inspire/cp/epsg-"$isrs"/"$ku".zip"
unzip $ku.zip


if [ $osrs = "5514" ] ; then
osrs="+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=0 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=570.8,85.7,462.8,4.998,1.587,5.261,3.56 +units=m +no_defs"
echo "osrs bude 5514"
#musi byt s mezerama, 
else
osrs="EPSG:$3"
fi



if [ $isrs = "5514" ] ; then
isrs="+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=0 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=570.8,85.7,462.8,4.998,1.587,5.261,3.56 +units=m +no_defs"
echo "isrs bude 5514"
#musi byt s mezerama, 
else
isrs="EPSG:$2"
fi

#echo "ogr2ogr -f ESRI Shapefile data/"$ku"_parcely.shp CP.gml -nlt MULTIPOLYGON -nln" $ku"_CP -s_srs "$isrs" -t_srs epsg:"$osrs "-skipfailures"


for x in CZ CP CB
do xsltproc -o $x.gml ../../lib/xsl/$x.xsl $ku.xml 
done

mkdir data
if [ $format = shp ] ; then
ogr2ogr -f "ESRI Shapefile" "data/"$ku"_parcely.shp" "CP.gml" -nlt MULTIPOLYGON -nln $ku"_CP" -s_srs "$isrs" -t_srs "$osrs" -skipfailures
ogr2ogr -f "ESRI Shapefile" "data/"$ku"_hranice.shp" "CB.gml" -nlt LINESTRING -nln $ku"_CB" -s_srs "$isrs" -t_srs  "$osrs" -skipfailures
ogr2ogr -f "ESRI Shapefile" "data/"$ku"_ku.shp" "CZ.gml" -nlt POLYGON -nln $ku"_CZ" -s_srs "$isrs" -t_srs "$osrs" -skipfailures
else
ogr2ogr -f $format "data/"$ku"_parcely."$format "CP.gml" -nlt MULTIPOLYGON -nln $ku"_CP" -s_srs "$isrs" -t_srs "$osrs" -skipfailures 
ogr2ogr -f $format "data/"$ku"_hranice."$format "CB.gml" -nlt LINESTRING -nln $ku"_CB" -s_srs "$isrs" -t_srs "$osrs" -skipfailures 
ogr2ogr -f $format "data/"$ku"_ku."$format "CZ.gml" -nlt POLYGON -nln $ku"_CZ" -s_srs "$isrs" -t_srs "$osrs" -skipfailures 
sed -i 's/amp;//g' "data/"$ku"_ku."$format
fi


zip -r $ku"_"$format data/*
#zazipuje slozku data

#find . ! -name $ku"_"$format'.zip' -delete

cd ../..
 
for i in `find data/ -maxdepth 1 -type d -mmin +30 -print`
do echo -e "Deleting directory $i" 
rm -rf $i
done
#prohleda adresar data a vymaze vsechny adresare starsi x minut

echo "/"$time"_"$ku"_"$pathosrs"_"$format"/"$ku"_"$format".zip" 
#chtelo by delat automaticky