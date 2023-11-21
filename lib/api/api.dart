import 'dart:convert';
import '../model/user.dart';
import 'package:http/http.dart' as http;

class API {
  static const hostConnect = "http://192.168.50.119/api_new_members";
  static const hostConnectUser = "$hostConnect/user";
  static const signup = "$hostConnect/user/signup.php";
  static const login = "$hostConnect/user/login.php";
  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const addEvent = "$hostConnect/user/add_event.php";
}