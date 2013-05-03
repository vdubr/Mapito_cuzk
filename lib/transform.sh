#$ku - cislo KU, $isrs - souradnicovy system(vstupni),$osrs - souradnicovy system(vystupni), $format - format
# sh trSHP.sh 624578 4258 4326 shp

#muze nastat problem
# ERROR 6: Unable to load PROJ.4 library (libproj.so), creation of OGRCoordinateTransformation failed 
# reseni
# sudo ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so
# sudo apt-get install zip

filepath=$1
filename=$2
isrs=$3
osrs=$4
iformat=$5
oformat=$6
itype=$7

cd "../data/"$filepath

if [ $3 = 5514 ] ; then
isrs = "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=0 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=570.8,85.7,462.8,4.998,1.587,5.261,3.56 +units=m +no_defs"
else
isrs=$3
fi

mkdir data
#musi byt - try cd/data else mkdir data cd data

if [ $oformat = shp ] ; then
ogr2ogr -f "ESRI Shapefile" $filename".shp" $filename"."$iformat "-nlt" $itype "-nln" $filename -s_srs "epsg:"$isrs -t_srs "epsg:"$osrs -skipfailures 
else
ogr2ogr -f $oformat $filename"."$oformat $filename"."$iformat "-nlt" $itype "-nln" $filename -s_srs "epsg:"$isrs -t_srs "epsg:"$osrs -skipfailures 
fi

