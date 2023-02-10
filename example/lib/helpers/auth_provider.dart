import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final CODE = "OAUTH_CODE";
  final ACCESS_TOKEN = "ACCESS_TOKEN";
  final REFRESH_TOKEN = "REFRESH_TOKEN";

  String? _code;
  String? _accessToken;
  String? _refreshToken;

  late SharedPreferences prefs;

  AuthProvider(this.prefs) {
    _code = prefs.getString(CODE);
    _accessToken = prefs.getString(ACCESS_TOKEN);
    _refreshToken = prefs.getString(REFRESH_TOKEN);
  }

  String? get oAuthCode => _code;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  getAccessToken() async {
    if (_code != null) {
      final clientID = dotenv.env['CLIENT_ID'];
      final clientSecret = dotenv.env['CLIENT_SECRET'];

      var basicAuth =
          'Basic ' + base64Encode(utf8.encode('$clientID:$clientSecret'));
      try {
        var response = await http.post(
          Uri.parse('https://zoom.us/oauth/token'),
          headers: {
            'Host': 'zoom.us',
            'Authorization': basicAuth,
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: {
            'code': _code,
            'grant_type': 'authorization_code',
            'redirect_uri': 'https://zoom.yashugarg.com/auth'
          },
        );

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          assignAccessToken(jsonResponse['access_token']);
          assignRefreshToken(jsonResponse['refresh_token']);
        } else {
          print('Request failed with status: ${response.body}.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> assignCode(String? code) async {
    _code = code;
    if (code != null) {
      await prefs.setString(CODE, code);
    } else {
      await prefs.remove(CODE);
    }
    getAccessToken();
    notifyListeners();
  }

  void assignAccessToken(String? accessToken) async {
    _accessToken = accessToken;
    if (accessToken != null) {
      await prefs.setString(ACCESS_TOKEN, accessToken);
    } else {
      await prefs.remove(ACCESS_TOKEN);
    }
    notifyListeners();
  }

  void assignRefreshToken(String? refreshToken) async {
    _refreshToken = refreshToken;
    if (refreshToken != null) {
      await prefs.setString(REFRESH_TOKEN, refreshToken);
    } else {
      await prefs.remove(REFRESH_TOKEN);
    }
    notifyListeners();
  }
}
