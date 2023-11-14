import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_mysql_tutorial/map/map.dart';


class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Center(
        child:ElevatedButton(
          onPressed: (){
            Get.to(() => MyMap());
          },
          child: Text('경로 안내'),
        ),
      ),
    );
  }
}