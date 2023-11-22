import 'dart:async';
//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'access_tokens.dart'; //access_tokens.dart 파일을 import
import 'get_user_location.dart'; //get_user_location.dart 파일을 import
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../api/api.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

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
  List<dynamic> eventList = [];
  LatLng origin =  LatLng(0, 0); // 초기값은 임의로 설정, 실제로는 위치 업데이트 후 값이 할당됩니다.
  LatLng destination =  LatLng(36.610869, 127.287040); // 도착지 좌표 (원하는 좌표로 교체하세요)
  GetLocation getLocation = GetLocation();
  late RouteData routeData; // Store route data
  Map<String, Uint8List> markerImages = {}; // Store marker images

  getEvents() async{
    dynamic id = await SessionManager().get("user_info");

    print('007000');
    print(id['user_id']);


    try {
      var res = await http.post(
          Uri.parse(API.getEvent),
          body: {
            'user_id': id['user_id']
          });

      if(res.statusCode == 200){
        var resEvent = jsonDecode(res.body);
        if(resEvent['success'] == true){
          eventList = resEvent['eventData'];
          print(eventList.length);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMarkerImage(); // Load marker image before initializing the map
    _initializeMap();
  }

  Future<void> _loadMarkerImage() async {
    markerImages['red_marker'] = await loadMarkerImage("assets/images/red_marker.png");
    markerImages['yellow_marker']= await loadMarkerImage("assets/images/yellow_marker.png");
  }
  //마커 이미지 경로 인식
  Future<Uint8List> loadMarkerImage(String imagePath) async {
    var byteData = await rootBundle.load(imagePath);
    return byteData.buffer.asUint8List();
  }

  // 비동기 함수 정의
  Future<void> _initializeMap() async {
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

      _controller.addImage('red_marker', markerImages['red_marker']!);
      _controller.addImage('yellow_marker', markerImages['yellow_marker']!);
      _controller.clearLines();
      _controller.clearSymbols();

      _controller.addLine(LineOptions(
        geometry: [origin, ...routeData.route, destination],
        lineColor: "#3bb2d0",
        lineWidth: 6.0,
        lineOpacity: 0.8,
      ));

      _controller.addSymbol(SymbolOptions(
        geometry: origin,
        iconImage: 'red_marker',
        iconSize: 0.1,
        textField: '현재 위치',
        textOffset: Offset(0, 2),
      ));

      _controller.addSymbol(SymbolOptions(
        geometry: destination,
        iconImage: 'yellow_marker',
        iconSize: 0.1,
        textField: '도착지',
        textOffset: Offset(0, 2),
      ));

    } catch (error) {
      print("지도 업데이트 오류: $error");
    }
  }

  //mapbox루트 정보 반환
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
        title: Text('Map Exampe'),
      ),
      body:  buildMap(),
      floatingActionButton: FloatingActionButton(
        // child: Text('Click'),
        child: Icon(Icons.location_searching),
        onPressed: ()=> {
          getEvents(),
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: ListView(
                  children: List.generate(
                    eventList.length, //리스트 개수(건물개수
                    (index) => GestureDetector(
                      onTap: () {
                        // Handle item click here
                        print("Item $index clicked");
                        //destination = eventList[index][10];
                        // You can add your logic to handle the click event
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          eventList[index][2] + '\n' + eventList[index][9],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            elevation: 50,
            isDismissible: true, // 바텀시트를 닫을지 말지 설정
            barrierColor: Colors.grey.withOpacity(0.3), // 바텀시트 아닌 영역의 컬러
            backgroundColor: Colors.blue.shade200, // 바텀시트 배경 컬러
            constraints: const BoxConstraints( // 사이즈 조절
              minWidth: 100,
              maxWidth: 300,
              minHeight: 100,
              maxHeight: 500,
            ),
            isScrollControlled: true, // true = 전체 화면 차이
          )
        },
      ),
    );
  }




  Widget buildMap() {
    return MapboxMap(
      accessToken: AppConstants.mapBoxAccessToken,
      styleString: MapboxStyles.SATELLITE_STREETS ,
      initialCameraPosition: CameraPosition(
        target: LatLng(36.61067, 127.2871), //고려대 세종캠퍼스 GPS
        zoom: 15.0,
      ),
      cameraTargetBounds: CameraTargetBounds( //최대 맵크기 제한
          LatLngBounds(
            southwest: LatLng(36.6012, 127.2776),
            northeast: LatLng(36.6162, 127.2982),
          )),
      minMaxZoomPreference: MinMaxZoomPreference(13, null), //최소 확대 레벨
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