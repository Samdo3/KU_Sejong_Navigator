import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_mysql_tutorial/map/map.dart';
import 'package:getx_mysql_tutorial/user/pages/timetable.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => MyMap());
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(120, 50), // Set the desired size for the button
              ),
              child: Text('경로 안내'),
            ),
            SizedBox(height: 20), // Add some spacing between the buttons
            ElevatedButton(
              onPressed: () {
                Get.to(() => Timetable());
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(120, 50), // Set the same size for the button
              ),
              child: Text('시간표'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}