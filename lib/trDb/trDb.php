
<?php

$x = $_GET["ku"];


$a= array();
$b=0;

//exec('sh trup.sh '.$x.' 5514 ligeo_ccc mapito radegast666',$a,$b );
exec('sh trup.sh '.$x.' 4258 ligeo_ccc mapito radegast666',$a,$b );

echo($b);
print_r($a);




?>
