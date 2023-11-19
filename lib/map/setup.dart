import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'access_tokens.dart'; //access_tokens.dart 파일을 import
import 'get_user_location.dart';
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
  LatLng origin =  LatLng(0, 0); // 초기값은 임의로 설정, 실제로는 위치 업데이트 후 값이 할당됩니다.
  LatLng destination =  LatLng(36.610869, 127.287040); // 도착지 좌표 (원하는 좌표로 교체하세요)
  GetLocation getLocation = GetLocation();
  late RouteData routeData; // Store route data
  late Uint8List markerImage; // Store marker image

  @override
  void initState() {
    super.initState();
    _loadMarkerImage(); // Load marker image before initializing the map
    _initializeMap();
  }

  Future<void> _loadMarkerImage() async {
    markerImage = await loadMarkerImage();
  }
  //마커 이미지 경로 인식
  Future<Uint8List> loadMarkerImage() async {
    var byteData = await rootBundle.load("assets/images/red_marker.png");
    return byteData.buffer.asUint8List();
  }

  // 비동기 함수 정의
  Future<void> _initializeMap() async {
    // 마커 이미지 추가
    getLocation.onLocationChanged = (LatLng newLocation) async {
      setState(() {
        origin = newLocation;
      });
      await _updateMapWithRoute();
    };

      await getLocation.determinePosition();
  }


  @override
  void dispose() {
    // 페이지가 소멸될 때 위치 업데이트 중지
    getLocation.stopLocationUpdates();
    super.dispose();
  }

  Future<void> _updateMapWithRoute() async {
    try {
      routeData = await fetchRoute();

      _controller.addImage('marker', markerImage);
      _controller.clearLines();
      _controller.clearSymbols();

      _controller.addLine(LineOptions(
        geometry: [origin, ...routeData.route, destination],
        lineColor: "#00FF00",
        lineWidth: 2.0,
      ));

      _controller.addSymbol(SymbolOptions(
        geometry: origin,
        iconImage: 'marker',
        iconSize: 0.5,
        textField: '현재 위치',
        textOffset: Offset(0, 2),
      ));

      _controller.addSymbol(SymbolOptions(
        geometry: destination,
        iconImage: 'marker',
        iconSize: 0.5,
        textField: '도착지',
        textOffset: Offset(0, 2),
      ));

    } catch (error) {
      print("지도 업데이트 오류: $error");
    }
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
      await _updateMapWithRoute(); // Update map after initializing controller
    } catch (error) {
      print("Error adding polyline: $error");
    }
      },
    );
  }
}