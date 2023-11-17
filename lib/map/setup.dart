import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'access_tokens.dart'; //access_tokens.dart 파일을 import
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteData {
  List<LatLng> route;
  List<LatLng> turnPoints;

  RouteData({required this.route, required this.turnPoints});
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxMapController _controller;
  List<LatLng> route = [];
  List<LatLng> turnPoints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Example'),
      ),
      body: buildMap(),
    );
  }

  Widget buildMap() {
    return MapboxMap(
      accessToken: AppConstants.mapBoxAccessToken,
      initialCameraPosition: CameraPosition(
        target: LatLng(36.61067, 127.2871), //사실 이 코드 숨길 필요없음
        zoom: 15.0,
      ),
      onMapCreated: (MapboxMapController controller) async {
        setState(() {
          _controller = controller;
        });

        try {
          RouteData routeData = await fetchRoute();
          var markerImage=await loadMarkerImage();

          // 마커 이미지 추가
          controller.addImage('marker',markerImage);

          // LineLayer를 사용하여 Polyline을 추가
          controller.addLine(LineOptions(
            geometry: route,
            lineColor: "#FF0000",
            lineWidth: 2.0,
          ));

          // 턴 포인트에 마커와 레이블 추가
          for (int i = 0; i < routeData.turnPoints.length; i++) {
            controller.addSymbol(SymbolOptions(
              geometry: routeData.turnPoints[i],
              iconImage: 'marker', // 사용자가 제공하는 아이콘 이미지로 변경
              iconSize: 0.5,
              textField: 'Turn ${i + 1}',
              textOffset: Offset(0, 2),
            ));
            // 추가된 마커

          }
        } catch (error) {
          print("Error adding polyline: $error");
        }
      },
    );
  }

  //마커 이미지 경로 인식
  Future<Uint8List> loadMarkerImage() async {
    var byteData = await rootBundle.load("assets/images/red_marker.png");
    return byteData.buffer.asUint8List();
  }

  Future<RouteData> fetchRoute() async {
    try {
      LatLng origin = LatLng(36.610866, 127.287018); // 출발지 좌표 (원하는 좌표로 교체하세요)
      LatLng destination = LatLng(36.608858, 127.289094); // 도착지 좌표 (원하는 좌표로 교체하세요)

      String routeResponse = (await http.get(
        Uri.parse(
          "https://api.mapbox.com/directions/v5/mapbox/walking/"
              "${origin.longitude},${origin.latitude};"
              "${destination.longitude},${destination.latitude}?"
              "access_token=${AppConstants.mapBoxAccessToken}&steps=true",
        ),
      )).body;

      print("Route Response: $routeResponse");
      var decodedResponse = json.decode(routeResponse);

      print("Decoded Response: $decodedResponse");
      // 루트 지오메트리 디코딩 예제
      List<PointLatLng> result = PolylinePoints()
          .decodePolyline(decodedResponse['routes'][0]['geometry'])
          .map((PointLatLng point) => point)
          .toList();

      // PointLatLng를 LatLng로 변환
      route = result.map((PointLatLng point) =>
          LatLng(point.latitude, point.longitude)).toList();

      List<dynamic> steps = decodedResponse['routes'][0]['legs'][0]['steps'] ?? [];

      List<LatLng> turnPoints=steps.map((step) => LatLng(
        step['maneuver']['location'][1],
        step['maneuver']['location'][0],
      )).toList();



      return RouteData(route: route, turnPoints: turnPoints);
    }catch (error) {
      print("Error fetching route: $error");
      // 에러 핸들링 또는 사용자에게 알림을 보여주는 등의 추가 작업이 가능합니다.
      throw error; // 에러를 호출한 곳으로 전파
    }
  }


}