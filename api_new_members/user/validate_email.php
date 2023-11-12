<?php
include '../connection.php';

$userEmail = $_POST['user_email'];

$sqlQuery = "SELECT * FROM user_table WHERE user_email = 'userEmail'";

$resultQuery = $connection->query($sqlQuery);

//0보다 크다는 것은 1이라는 의미이고 다른 사람이 사용중이니 signup이 불가하다.
//else는 num_rows가 0이므로 사용중인 사람이 없으니 가능하다.
if ($resultQuery->num_rows > 0) {
    echo json_encode(array("existEmail" => true));
} else {
    echo json_encode(array("existEmail" => false));
}
