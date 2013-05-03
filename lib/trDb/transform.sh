#$ku - cislo KU, $isrs - souradnicovy system(vstupni),$osrs - souradnicovy system(vystupni), $format - format
# sh trSHP.sh 624578 4258 4326 shp

#muze nastat problem
# ERROR 6: Unable to load PROJ.4 library (libproj.so), creation of OGRCoordinateTransformation failed 
# reseni
# sudo ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so
# sudo apt-get install zip



ku=$1
osrs=$3
format=$4

if [ $2 = 5514 ] ; then
isrs = "+proj=krovak +lat_0=49.5 +lon_0=24.83333333333333 +alpha=0 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +towgs84=570.8,85.7,462.8,4.998,1.587,5.261,3.56 +units=m +no_defs"
else
isrs=$2
fi

cd ../../data
mkdir $time"_"$ku"_"$isrs
cd $time"_"$ku"_"$isrs

wget "services.cuzk.cz/gml/inspire/cp/epsg%2D"$isrs"/"$ku".zip"
unzip $ku.zip

for x in CZ CP CB
do xsltproc -o $x.gml ../../xsl/$x.xsl $ku.xml 
#do xsltproc -o $x"_"$ku.gml ../../CG.xsl $1.xml - pridava sloupec s odkazem na kn, problem s ampersandem
done

mkdir data
if [ $format = shp ] ; then
ogr2ogr -f "ESRI Shapefile" "data/"$ku"_parcely.shp" "CP.gml" -nlt MULTIPOLYGON -nln $ku"_CP" -s_srs "epsg:"$isrs -t_srs "epsg:"$osrs -skipfailures 
ogr2ogr -f "ESRI Shapefile" "data/"$ku"_hranice.shp" "CB.gml" -nlt LINESTRING -nln $ku"_CB" -s_srs "epsg:"$isrs -t_srs "epsg:"$osrs -skipfailures 
ogr2ogr -f "ESRI Shapefile" "data/"$ku"_ku.shp" "CZ.gml" -nlt POLYGON -nln $ku"_CZ" -s_srs "epsg:"$isrs -t_srs "epsg:"$osrs -skipfailures 
else
ogr2ogr -f $format "data/"$ku"_parcely."$format "CP.gml" -nlt MULTIPOLYGON -nln $ku"_CP" -s_srs "epsg:"$isrs -t_srs "epsg:"$osrs -skipfailures 
ogr2ogr -f $format "data/"$ku"_hranice."$format "CB.gml" -nlt LINESTRING -nln $ku"_CB" -s_srs "epsg:"$isrs -t_srs "epsg:"$osrs -skipfailures 
ogr2ogr -f $format "data/"$ku"_ku."$format "CZ.gml" -nlt POLYGON -nln $ku"_CZ" -s_srs "epsg:"$isrs -t_srs "epsg:"$osrs -skipfailures 
fi

zip -r $ku data/*
#zazipuje slozku data

find . ! -name $ku'.zip' -delete
#odstrani vse krome data.zip

cd ../..
 
for i in `find data/ -maxdepth 1 -type d -mmin +30 -print`
do echo -e "Deleting directory $i" 
rm -rf $i
done
#prohleda adresar data a vymaze vsechny adresare starsi x minut

echo "http://158.196.109.32/lab1/Mapito/module/cuzk/data/"$time"_"$ku"_"$isrs"_"$osrs"_"$format"/"$ku".zip" 
#chtelo by delat automaticky


