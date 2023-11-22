import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_timetable_view/flutter_timetable_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../api/api.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TimeTable View Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Timetable(),
    );
  }
}

class Timetable extends StatefulWidget {
  Timetable({Key? key}) : super(key: key);

  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  List<LaneEvents> laneEventsList = [];
  TextEditingController titleController = TextEditingController();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();
  String selectedDay = 'Monday';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Timetable View Demo'),
      ),
      body: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddEventDialog(context),
                  child: Text('Add Event'),
                ),
                SizedBox(width: 16), // Adjust the spacing between buttons
                ElevatedButton(
                  onPressed: () {
                    _showEventsList(laneEventsList);
                  },
                  child: Text('View Events'),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: selectedDay,
            onChanged: (String? newValue) {
              setState(() {
                selectedDay = newValue!;
              });
            },
            items: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          // Timetable
          Expanded(
            child: TimetableView(
              laneEventsList: laneEventsList,
              timetableStyle: TimetableStyle(
                startHour: 9,
                endHour: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    String className = '';
    String buildingInfo = '과학기술2관'; // 기본값은 '과학기술1관'으로 설정

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Event"),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  className = value;
                },
                decoration: InputDecoration(
                  labelText: 'Class Name',
                  hintText: 'Enter class name',
                ),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: buildingInfo,
                onChanged: (String? newValue) {
                  setState(() {
                    buildingInfo = newValue!;
                  });
                },
                items: <String>[
                  '과학기술2관',
                  '과학기술1관',
                  '가속기ICT융합관',
                  '산학협력관',
                  '농심국제관',
                  '공공정책관',
                  '석원경상관',
                  '문화스포츠관',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Start Time: ${selectedStartTime.format(context)}'),
                  ElevatedButton(
                    onPressed: () => _selectStartTime(context),
                    child: Text('Set Time'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('End Time: ${selectedEndTime.format(context)}'),
                  ElevatedButton(
                    onPressed: () => _selectEndTime(context),
                    child: Text('Set Time'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addEvent(className, buildingInfo, selectedDay);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildEventRows(LaneEvents laneEvents) {
    return [
      Text('${laneEvents.lane.name} Events', style: TextStyle(fontWeight: FontWeight.bold)),
      for (TableEvent event in laneEvents.events)
        _buildEventRow(event, laneEvents),
      SizedBox(height: 10),
    ];
  }

  Widget _buildEventRow(TableEvent event, LaneEvents laneEvents) {
    final startTime = TimeOfDay(hour: event.start.hour, minute: event.start.minute);
    final endTime = TimeOfDay(hour: event.end.hour, minute: event.end.minute);

    final startTimeString = _formatTimeOfDay(startTime);
    final endTimeString = _formatTimeOfDay(endTime);

    return ListTile(
      title: Text('${event.title} ($startTimeString - $endTimeString)'),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _deleteEvent(laneEvents, event);
          Navigator.pop(context);
        },
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return TimeOfDay.fromDateTime(dateTime).format(context);

  }

  void _deleteEvent(LaneEvents laneEvents, TableEvent event) {
    setState(() {
      laneEvents.events.remove(event);
      _saveEvents();
    });
  }

  void _showEventsList(List<LaneEvents> laneEventsList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('All Events'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (LaneEvents laneEvents in laneEventsList)
                ..._buildEventRows(laneEvents),
            ],
          ),
        );
      },
    );
  }

  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );
    if (picked != null && picked != selectedStartTime) {
      setState(() {
        selectedStartTime = picked.period == DayPeriod.pm
            ? picked
            : TimeOfDay(hour: picked.hour % 12, minute: picked.minute);
      });
    }
  }

  void _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );
    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked.period == DayPeriod.pm
            ? picked
            : TimeOfDay(hour: picked.hour % 12, minute: picked.minute);
      });
    }
  }

  TimeOfDay _convertTo12HourFormat(TimeOfDay time) {
    int hour = time.hourOfPeriod;
    int minute = time.minute;
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _addEvent(String className, String buildingInfo, String selectedDay) async {
    if (className.isNotEmpty && buildingInfo.isNotEmpty) {

      dynamic id = await SessionManager().get("user_info");
      print(id);

      try {
        DateTime now = DateTime.now();
        String formattedDate = "${now.year}-${now.month}-${now.day}";

        var res = await http.post(
          Uri.parse(API.addEvent),
          body: {
            'user_id': id['user_id'],
            'class_name': className,
            'building_info': buildingInfo,
            'start_time': selectedStartTime.format(context),
            'end_time': selectedEndTime.format(context),
            'day': selectedDay,
            'date_added': formattedDate,
          },
        );

        print('Server Response: $res');

        if (res.statusCode == 200) {
          var resData = jsonDecode(res.body);
          if (resData['success'] == true) {
            TableEvent addedEvent = TableEvent(
              title: '$className - $buildingInfo',
              start: TableEventTime(
                hour: selectedStartTime.hour,
                minute: selectedStartTime.minute,
              ),
              end: TableEventTime(
                hour: selectedEndTime.hour,
                minute: selectedEndTime.minute,
              ),
            );

            _updateLocalTimetable(selectedDay, addedEvent);

            Fluttertoast.showToast(msg: 'Event added successfully');
          } else {
            Fluttertoast.showToast(msg: 'Error: ${resData['error']}');
          }
        } else {
          print('Server Response Body: ${res.body}');
          Fluttertoast.showToast(msg: 'Error: Unexpected response from server');
        }

      } catch (e) {
        print('Error during event addition: $e');
        print(e.toString());
        Fluttertoast.showToast(msg: 'Error occurred. Please try again');
      }
    } else {
      print('Please enter class name and building information');
    }

  }

  void _updateLocalTimetable(String day, TableEvent event) {
    setState(() {
      LaneEvents laneEvents = laneEventsList.firstWhere(
            (element) => element.lane.name == day,
        orElse: () {
          LaneEvents newLaneEvents = LaneEvents(
            lane: Lane(name: day),
            events: [],
          );
          laneEventsList.add(newLaneEvents);
          return newLaneEvents;
        },
      );

      laneEvents.events.add(event);

      _saveEvents();
    });
  }

  void _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsString = prefs.getString('events');
    if (eventsString != null) {
      setState(() {
        laneEventsList = LaneEventsList.fromJson(eventsString).laneEventsList;
      });
    }
  }


  void _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventsString = LaneEventsList(laneEventsList: laneEventsList).toJson();
    prefs.setString('events', eventsString);
  }
}

class LaneEventsList {
  List<LaneEvents> laneEventsList;

  LaneEventsList({required this.laneEventsList});

  String toJson() {
    List<Map<String, dynamic>> eventsListMap = laneEventsList.map((laneEvents) {
      return {
        'lane': {'name': laneEvents.lane.name},
        'events': laneEvents.events.map((event) {
          return {
            'title': event.title,
            'start': {
              'hour': event.start.hour,
              'minute': event.start.minute,
            },
            'end': {
              'hour': event.end.hour,
              'minute': event.end.minute,
            },
          };
        }).toList(),
      };
    }).toList();

    return jsonEncode(eventsListMap);
  }

  factory LaneEventsList.fromJson(String jsonString) {
    List<dynamic> eventsListMap = jsonDecode(jsonString);
    List<LaneEvents> laneEventsList = eventsListMap.map((eventMap) {
      return LaneEvents(
        lane: Lane(name: eventMap['lane']['name']),
        events: (eventMap['events'] as List<dynamic>).map((event) {
          return TableEvent(
            title: event['title'],
            start: TableEventTime(
              hour: event['start']['hour'],
              minute: event['start']['minute'],
            ),
            end: TableEventTime(
              hour: event['end']['hour'],
              minute: event['end']['minute'],
            ),
          );
        }).toList(),
      );
    }).toList();

    return LaneEventsList(laneEventsList: laneEventsList);
  }
}