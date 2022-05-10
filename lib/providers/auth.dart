import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireyDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    // if (_expireyDate != null &&
    //     _expireyDate.isAfter(DateTime.now()) &&
    //     _token != null) {
    if (_expireyDate != null && _expireyDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String? email, String? password, String? urlSegmant) async {
    final url = Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:$urlSegmant',
        {'key': 'AIzaSyDkQD1r7v1yyiarWM5ePOs1jk7Sr9ZZBuM'});
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireyDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expireyDate': _expireyDate?.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      print('authenticate error $error');
      throw error;
    }
  }

  Future<void> signup(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final exUserData = json.decode(prefs.getString('userData').toString());
    // as Map<String, String>;

    final expiryData = DateTime.parse(exUserData['expireyDate'].toString());
    if (expiryData.isBefore(DateTime.now())) {
      return false;
    }
    _token = exUserData['token'];
    _userId = exUserData['userId'];
    _expireyDate = expiryData;
    notifyListeners();
    autoLogout();
    return true;
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expireyDate = null;
    _authTimer = null;
    _authTimer?.cancel();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    _authTimer?.cancel();
    final timer = _expireyDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timer), logout);
  }
}
