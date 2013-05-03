#$ku - cislo KU, $isrs - souradnicovy system(vstupni),$osrs - souradnicovy system(vystupni), $format - format
# sh trSHP.sh 624578 4258 4326 shp

#muze nastat problem
# ERROR 6: Unable to load PROJ.4 library (libproj.so), creation of OGRCoordinateTransformation failed 
# reseni
# sudo ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so
# sudo apt-get install zip



cd "../data/"$1

zip -r data data/*
#zazipuje slozku data

find . ! -name 'data.zip' -delete
#odstrani vse krome data.zip

cd ../..
 
for i in `find data/ -maxdepth 1 -type d -mmin +30 -print`
do echo -e "Deleting directory $i" 
rm -rf $i
done
#prohleda adresar data a vymaze vsechny adresare starsi x minut

echo "http://158.196.109.32/lab1/Mapito/module/cuzk/data/"$1"/data.zip" 
#chtelo by delat automaticky


