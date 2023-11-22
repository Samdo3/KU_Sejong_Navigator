<?php
include '../connection.php';

$userID = $_POST['user_id'];

$sqlQuery = "SELECT `event_table`.*, `building_table`.`b_id` as `b_idx`, `building_table`.`b_name`, `building_table`.`b_gps` FROM `event_table` LEFT JOIN `building_table` ON `event_table`.`building_info` = `building_table`.`b_name` WHERE `user_id` = " . $userID;
$resultQuery = $connection->query($sqlQuery);

if ($resultQuery->num_rows > 0) {

    $eventRecord = array();
    while ($rowFound = $resultQuery->fetch_all()) {
        $eventRecord[] = $rowFound;
    }
    echo json_encode(
        array(
            "success" => true,
            "eventData" => $eventRecord[0]
        )
    );
} else {
    echo json_encode(array("success" => false));
}
