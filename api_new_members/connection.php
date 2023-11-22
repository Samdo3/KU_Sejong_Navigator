<?php
$myServer = "localhost";
$user = "root";
$password = "";
$database = "new_members";

$connection = new mysqli($myServer, $user, $password, $database);

if ($connection->connect_error) {
    die(json_encode(array("success" => false, "error" => "Connection failed: " . $connection->connect_error)));
}
