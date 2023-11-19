import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'access_tokens.dart'; //access_tokens.dart 파일을 import
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';


class MyMap extends StatefulWidget {
  const MyMap({Key? key}) : super(key:key);

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final MapController mapController = MapController();
  LatLng? userLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 32, 32),
        title: const Text('Flutter MapBox'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialZoom: 13,
              initialCenter: AppConstants.myLocation,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://api.mapbox.com/styles/v1/samdo333/clotzji9s007101pqg3hj2em4/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic2FtZG8zMzMiLCJhIjoiY2xvZTA4ZHVxMDk2NTJwbzNxM2UyaWp2YSJ9.aAEN_UMKlCKHalOa7Tkg0Q",
                additionalOptions: {
                  'accessToken': AppConstants.mapBoxAccessToken,
                },
              ),
              MarkerLayer(
                markers: [
                  if (userLocation != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: userLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                getUserLocation();
              },
              child: const Text('Show My Location'),
            ),
          ),
        ],
      ),
    );
  }

  void getUserLocation() async {
    // 위치 권한이 부여되었는지 확인
    bool isLocationPermissionGranted = await _checkLocationPermission();

    if (isLocationPermissionGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        LatLng newLocation = LatLng(position.latitude, position.longitude);

        setState(() {
          userLocation = newLocation;
          mapController.move(newLocation, 19.0);
        });
      } catch (e) {
        print('사용자 위치 가져오기 오류: $e');
        showToast('사용자 위치 가져오기 오류: $e');
      }
    } else {
      // 위치 권한이 부여되지 않았을 경우 메시지 표시 또는 권한 요청
      showToast('위치 권한이 부여되지 않았습니다.');
      _requestLocationPermission();
    }
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
