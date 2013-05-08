
<?php

#sudo apt-get install php5-curl
#sudo service apache2 restart

$a = split("/", $_SERVER["SCRIPT_NAME"]);
$addr = "";

for ($i = 0; $i < (count($a) - 3); $i++) {
    if ($a[$i])
        $addr .="/" . $a[$i];
}
$html = "http://" . $_SERVER["SERVER_NAME"] . "$addr/data";

$ku = $_GET["ku"];
$isrs = $_GET["isrs"];
$osrs = $_GET["osrs"];
$format = $_GET["format"];
$time = Time();

//PHP vytvari adresar kvuli opraavneni, aby se nemusel provadet "chmod 777 data"
mkdir("../../data/".$time."_".$ku."_".$osrs."_".$format, 0777);

exec('sh trFile.sh ' . $ku . ' ' . $isrs . ' ' . $osrs . ' ' . $format . ' ' . $time, $pole);

//print_r($pole);
print($pole[count($pole) - 1]);
?>
