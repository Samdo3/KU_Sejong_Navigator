import 'dart:convert';
import '../model/user.dart';
import 'package:http/http.dart' as http;

class API {
  static const hostConnect = "http://내 아이피/api_new_members";
  static const hostConnectUser = "$hostConnect/user";
  static const signup = "$hostConnect/user/signup.php";
  static const login = "$hostConnect/user/login.php";
  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const addEvent = "$hostConnect/user/add_event.php";
  static const getEvent = "$hostConnect/user/get_event.php";
  static const deleteEvent ="$hostConnect/user/delete_event.php";
}