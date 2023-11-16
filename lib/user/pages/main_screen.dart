import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:getx_mysql_tutorial/map/map.dart';
import 'package:getx_mysql_tutorial/map/setup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';


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
            _AskLocationPermission();
          },
          child: Text('경로 안내'),
        ),
      ),
    );
  }
  void _AskLocationPermission() async {
    // 위치 권한이 부여되었는지 확인
    bool isLocationPermissionGranted = await _checkLocationPermission();

    if (isLocationPermissionGranted) {
      Get.to(() => MapScreen());
    } else {
      // 위치 권한이 부여되지 않았을 경우 메시지 표시 또는 권한 요청
      showToast('위치 권한이 부여되지 않았습니다.');
      _requestLocationPermission();
    }
  }

  Future<bool> _checkLocationPermission() async {
    // 위치 권한이 부여되었는지 확인
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      // 권한이 부여되지 않았다면 요청
      return await _requestLocationPermission();
    }
  }

  Future<bool> _requestLocationPermission() async {
    // 위치 권한 요청
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  void showToast(String message) {  //토스트 형식
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}