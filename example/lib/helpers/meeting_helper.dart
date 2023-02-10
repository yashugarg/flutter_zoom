import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class MeetingHelper {
  String? zoomAccessTokenZAK;
  String sdkKey = dotenv.env['APP_KEY'] ?? "";
  String sdkSecret = dotenv.env['APP_SECRET'] ?? "";

  joinMeeting(
    BuildContext context, {
    TextEditingController? displayNameController,
    required TextEditingController meetingIdController,
    required TextEditingController meetingPasswordController,
    Timer? timer,
  });

  startMeeting(
    BuildContext context, {
    required String accessToken,
    required String meetingId,
    required String hostEmail,
    Timer? timer,
  });

  String generateJWT(String meetingNumber, int role) {
    final iat = (DateTime.now().millisecondsSinceEpoch - 30000) ~/ 1000;
    final exp = iat + (60 * 60 * 2);
    final tokenExp = exp + (60 * 60 * 2);

    final jwt = JWT(
      {
        "appKey": sdkKey,
        "sdkKey": sdkKey,
        "mn": meetingNumber,
        "role": role,
        "iat": iat,
        "exp": exp,
        "tokenExp": tokenExp,
      },
      issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
    );

    // Sign it
    final token = jwt.sign(SecretKey(sdkSecret));

    print('Signed token: $token\n');
    return token;
  }

  initZAK(String accessToken) async {
    try {
      var response = await http.get(
        Uri.parse('https://api.zoom.us/v2/users/me/token?type=zak'),
        headers: {
          'Authorization': "Bearer " + accessToken,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        zoomAccessTokenZAK = jsonResponse['token'];
      } else {
        print('Request failed with status: ${response.body}.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, String>> createMeeting(String accessToken) async {
    try {
      // https://marketplace.zoom.us/docs/api-reference/zoom-api/methods/#operation/meetingCreate
      var response = await http.post(
        Uri.parse('https://api.zoom.us/v2/users/me/meetings'),
        headers: {
          'Authorization': "Bearer " + accessToken,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "default_password": false,
          "duration": 30,
          "host_video": true,
        }),
      );
      var jsonResponse = jsonDecode(response.body);
      // print(jsonResponse);
      return {
        "id": jsonResponse["id"].toString(),
        "host_email": jsonResponse["host_email"],
        "zak":
            Uri.parse(jsonResponse["start_url"]).queryParameters["zak"] ?? "",
      };
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
