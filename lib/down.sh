#$ku - cislo KU, $isrs - souradnicovy system(vstupni),$osrs - souradnicovy system(vystupni), $oformat - format
#pokud je jako typ db je potreba jeste zadat user , db , pass

# sh down.sh 624578 5514 4326 shp

#muze nastat problem
# ERROR 6: Unable to load PROJ.4 library (libproj.so), creation of OGRCoordinateTransformation failed 
# reseni
# sudo ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so
# sudo apt-get install zip

#

time=$(date +%s)

ku=$1
isrs=$2
osrs=$3
oformat=$4

cd ../data
mkdir $time"_"$ku"_"$osrs"_"$oformat
cd $time"_"$ku"_"$osrs"_"$oformat

wget "services.cuzk.cz/gml/inspire/cp/epsg%2D"$isrs"/"$ku".zip"
unzip $ku.zip
rm -rf $ku.zip


###########################for start
for x in CZ CP CB

do xsltproc -o $x.gml ../../lib/xsl/$x.xsl $ku.xml 
#do xsltproc -o $x"_"$ku.gml ../../CG.xsl $1.xml - pridava sloupec s odkazem na kn, problem s ampersandem

if [ $x = CZ ] ; then
itype=POLYGON
elif [ $x = CP ] ; then
itype=MULTIPOLYGON
else
itype=LINESTRING
fi

if [ $oformat = db ] ; then
user=$5
db=$6
pass=$7

bash importtodb.sh $time"_"$ku"_"$osrs"_"$oformat $x $isrs $osrs gml $oformat $itype $user $db $pass $ku"_"$x

else
bash transform.sh $time"_"$ku"_"$osrs"_"$oformat $x $isrs $osrs gml $oformat $itype
fi

done
###########################for end
cd ../..

if [ $oformat = db ] ; then
#pokud je typ db provede se po importu smazani cele slozky
rm -rf $time"_"$ku"_"$osrs"_"$oformat

else

#bash zip.sh $time"_"$ku"_"$osrs"_"$oformat
zip -r data data/$time"_"$ku"_"$osrs"_"$oformat/data/*
find data/$time"_"$ku"_"$osrs"_"$oformat/. ! -name 'data.zip' -delete
echo "http://158.196.109.32/lab1/Mapito/module/cuzk/data/"$time"_"$ku"_"$osrs"_"$oformat"/data.zip" 

fi


for i in `find data/ -maxdepth 1 -type d -mmin +30 -print`
do rm -rf $i
done


