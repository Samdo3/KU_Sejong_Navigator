<?php
include '../connection.php';

// $userID = $_POST['user_id'];
// $className = $_POST['class_name'];
// $buildingInfo = $_POST['building_info'];
// $startTime = $_POST['start_time'] . ":00";
// $endTime = $_POST['end_time'] . ":00";
// $day = $_POST['day'];
// $dateAdded = $_POST['date_added'];
$userID = $_POST['user_id'];
$className = $_POST['class_name'];

// $sqlQuery = "DELETE FROM event_table WHERE (user_id, class_name, building_info, start_time, end_time, day, date_added)
// VALUES (?, ?, ?, ?, ?, ?, ?)";
$sqlQuery = 'DELETE FROM `event_table` WHERE `user_id` = ? AND `class_name` = ?';

$stmt = $connection->prepare($sqlQuery);
$stmt->bind_param("is", $userID, $className);
$resultQuery = $stmt->execute();

if (!$resultQuery) {
    echo json_encode(array("success" => false, "error" => $stmt->error));
} else {
    echo json_encode(array("success" => true));
}
