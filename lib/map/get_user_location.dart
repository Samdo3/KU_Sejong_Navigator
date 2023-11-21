import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl_platform_interface/mapbox_gl_platform_interface.dart';

class GetLocation {
  late void Function(LatLng) onLocationChanged;
  late StreamSubscription<Position> positionStream;


  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    } else if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // 위치 업데이트를 받기 시작
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
          if (position != null) {
            // 위치가 업데이트되었을 때 콜백 함수를 호출하여 위치 데이터 전달
            final LatLng newLocation = LatLng(
                position.latitude, position.longitude);
            onLocationChanged(newLocation);
          }
        });
  }

  // 위치 업데이트 중지
  void stopLocationUpdates() {
    if (positionStream != null) {
      positionStream.cancel();
    }
  }
}

