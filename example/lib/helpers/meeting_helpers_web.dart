import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_zoom/flutter_zoom_web.dart';
import 'package:universal_html/html.dart';

import 'package:flutter_zoom_example/helpers/meeting_helper.dart';

class MeetingHelperSub extends MeetingHelper {
  @override
  joinMeeting(
    BuildContext context, {
    required TextEditingController meetingIdController,
    required TextEditingController meetingPasswordController,
    TextEditingController? displayNameController,
    Timer? timer,
  }) async {
    if (meetingIdController.text.isNotEmpty &&
        meetingPasswordController.text.isNotEmpty) {
      final jwtToken = generateJWT(meetingIdController.text, 0);
      ZoomOptions zoomOptions = ZoomOptions(
        domain: "zoom.us",
        appKey: dotenv.env['APP_KEY'],
        appSecret: dotenv.env['APP_SECRET'],
      );
      var meetingOptions = ZoomMeetingOptions(
        displayName: displayNameController?.text,
        meetingId: meetingIdController.text,
        meetingPassword: meetingPasswordController.text,
        userId: "User",
        jwtAPIKey: dotenv.env['APP_KEY'],
        jwtSignature: jwtToken,
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        disableTitlebar: "false",
        viewOptions: "true",
        noAudio: "false",
        noDisconnectAudio: "false",
      );

      var zoom = ZoomViewWeb();
      zoom.initZoom(zoomOptions).then((results) {
        if (results[0] == 0) {
          var zr = window.document.getElementById("zmmtg-root");
          querySelector('body')?.append(zr!);
          zoom.onMeetingStatus().listen((status) {
            if (kDebugMode) {
              print(
                  "[Meeting Status Stream] : " + status[0] + " - " + status[1]);
            }
          });
          zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
            // print("[Meeting Status Polling] : " +
            //     joinMeetingResult[0] +
            //     " - " +
            //     joinMeetingResult[1]);
          });
        }
      }).catchError((error) {
        print("[Error Generated] : " + error);
      });
    }
  }

  @override
  startMeeting(BuildContext context,
      {required String accessToken,
      required String meetingId,
      required String hostEmail,
      Timer? timer}) {
    // TODO: implement startMeeting
    throw UnimplementedError();
  }
}
