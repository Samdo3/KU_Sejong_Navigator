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
  LatLng origin = LatLng(36.609358, 127.287593); // 출발지 좌표 (원하는 좌표로 교체하세요)
  LatLng destination = LatLng(36.609269, 127.288783); // 도착지 좌표 (원하는 좌표로 교체하세요)

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

    // origin x / destination x
    if (!isPointOnRoute(origin, routeData) && !isPointOnRoute(destination, routeData)) {
    controller.addLine(LineOptions(
    geometry: [origin, ...route, destination],
    lineColor: "#00FF00", // 라인 색상 (녹색)
    lineWidth: 2.0,
    ));
    }
    // origin x / destination o
    else if (!isPointOnRoute(origin, routeData)) {
    controller.addLine(LineOptions(
    geometry: [origin, ...route],
    lineColor: "#00FF00",
    lineWidth: 2.0,
    ));
    }
    // origin o / destination x
    else if (!isPointOnRoute(destination, routeData)) {
      controller.addLine(LineOptions(
        geometry: [...route, destination],
        lineColor: "#0000FF",
        lineWidth: 2.0,
      ));
    }
    // origin o / destination o
    else {
      controller.addLine(LineOptions(
        geometry: route,
        lineColor: "#FF0000",
        lineWidth: 2.0,
      ));
    }
    // 출발지 심볼 추가
    controller.addSymbol(SymbolOptions(
      geometry: origin,
      iconImage: 'marker',
      iconSize: 0.5,
      textField: '출발지',
      textOffset: Offset(0, 2),
    ));
    // 목적지 심볼 추가
    controller.addSymbol(SymbolOptions(
      geometry: destination,
      iconImage: 'marker',
      iconSize: 0.5,
      textField: '도착지',
      textOffset: Offset(0, 2),
    ));
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

      String routeResponse = (await http.get(
        Uri.parse(
          "https://api.mapbox.com/directions/v5/mapbox/walking/"
              "${origin.longitude},${origin.latitude};"
              "${destination.longitude},${destination.latitude}?"
              "access_token=${AppConstants.mapBoxAccessToken}"
              "&steps=true&language=ko&walkway_bias=-0.2&overview=full"
              //walkway_bias=-0.2로 고정
        ),
      )).body;

      print("Route Response: $routeResponse");
      var decodedResponse = json.decode(routeResponse);

      print("Decoded Response: $decodedResponse");

      // route 매핑
      List<PointLatLng> result = PolylinePoints()
          .decodePolyline(decodedResponse['routes'][0]['geometry'])
          .map((PointLatLng point) => point)
          .toList();
      route = result.map((PointLatLng point) =>
          LatLng(point.latitude, point.longitude)).toList();

      //turnPoints 매핑(symbol추가 안해서 안보임)
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

  // 특정 지점이 경로 상에 있는지 확인하는 함수
  bool isPointOnRoute(LatLng point, RouteData routeData) {
    return routeData.route.contains(point);
  }


}