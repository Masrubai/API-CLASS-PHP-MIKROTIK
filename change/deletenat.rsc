<?php
use PEAR2\Net\RouterOS;
// require_once 'pear2\src\PEAR2\Autoload.php';
require_once 'PEAR2_Net_RouterOS-1.0.0b4.phar';

$client = new RouterOS\Client('192.168.150.161', 'admin', 'admin');

if (isset($_POST['act'])) {
    foreach ($_POST['act'] as $act => $itemID) {
        //Limit the action only to known ones, for security's sake
        if (in_array($act, array('set', 'remove'))) {
            $actionRequest = new RouterOS\Request("/ip/firewall/nat/{$act}");
            $actionRequest->setArgument('numbers', $itemID);
            if ('set' === $act) {
                foreach ($_POST[$itemID] as $name => $value) {
                    $actionRequest->setArgument($name, $value);
                }
            }
            $responses = $client->sendSync($actionRequest);
            $errors = $responses->getAllOfType(RouterOS\Response::TYPE_ERROR);
            if (0 === count($errors)) {
                echo "<div>'{$act}' OK!</div>";
            } else {
                echo '<div><ul>';
                foreach ($errors as $error) {
                    echo '<li>' . $error('message') . '</li>';
                }
                echo '</ul></div>';
            }
        }
    }
}

// Tabla

echo "<table align='center' border=1 bordercolor='black'>";
echo "<tr><td align=left size=3>Src Address</td><td size=3>To Addresses</td><td size=3>Ports</td><td align=left size=3>Modificar/Eliminar</td></tr>";

// Peticion a la API 
$responses = $client->sendSync(new RouterOS\Request('/ip/firewall/nat/print'));


 echo "<form action='' method='POST'>";
 
foreach ($responses as $response) {
    if ($response->getType() === RouterOS\Response::TYPE_DATA) {
      $id = $response('.id');
      echo "<tr>";
      echo "<td><input type='text' name='{$id}[src-address]' value='" . $response('src-address'). "' /></td>";
      echo "<td><input type='text' name='{$id}[to-addresses]' value='" . $response('to-addresses'). "' /></td>";
      echo "<td><input type='text' name='{$id}[to-ports]' value='" . $response('to-ports'). "' /></td>";

      //Boton Modificar
      echo "<td><button type='submit' name='act[set]' value='{$id}'>Modificar</button>";
      //Boton Borrar
      echo "<button type='submit' name='act[remove]' value='{$id}'>Borrar</button></td>";
      echo "</tr>";
    }
}
echo "</form>";
echo "</table>";

?>

https://forum.mikrotik.com/viewtopic.php?t=77816
