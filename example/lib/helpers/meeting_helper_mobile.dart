import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_zoom/zoom_options.dart';
import 'package:flutter_zoom/zoom_view.dart';

import 'package:flutter_zoom_example/helpers/meeting_helper.dart';

class MeetingHelperSub extends MeetingHelper {
  bool _isMeetingEnded(String status) {
    var result = false;

    if (Platform.isAndroid) {
      result = status == "MEETING_STATUS_DISCONNECTING" ||
          status == "MEETING_STATUS_FAILED";
    } else {
      result = status == "MEETING_STATUS_IDLE";
    }

    return result;
  }

//API KEY & SECRET is required for below methods to work
//Join Meeting With Meeting ID & Password
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
        jwtToken: jwtToken,
      );
      var meetingOptions = ZoomMeetingOptions(
        displayName: displayNameController?.text,
        meetingId: meetingIdController.text,
        meetingPassword: meetingPasswordController.text,
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        disableTitlebar: "false",
        viewOptions: "true",
        noAudio: "false",
        noDisconnectAudio: "false",
      );

      var zoom = ZoomView();
      zoom.initZoom(zoomOptions).then((results) {
        if (results[0] == 0) {
          zoom.onMeetingStatus().listen((status) {
            if (kDebugMode) {
              print(
                  "[Meeting Status Stream] : " + status[0] + " - " + status[1]);
            }
            if (_isMeetingEnded(status[0])) {
              if (kDebugMode) {
                print("[Meeting Status] :- Ended");
              }
              timer?.cancel();
            }
          });
          if (kDebugMode) {
            print("listen on event channel");
          }
          zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
            timer = Timer.periodic(const Duration(seconds: 2), (timer) {
              zoom.meetingStatus(meetingOptions.meetingId!).then((status) {
                if (kDebugMode) {
                  print("[Meeting Status Polling] : " +
                      status[0] +
                      " - " +
                      status[1]);
                }
              });
            });
          });
        }
      }).catchError((error) {
        if (kDebugMode) {
          print("[Error Generated] : " + error);
        }
      });
    } else {
      if (meetingIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Enter a valid meeting id to continue."),
        ));
      } else if (meetingPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Enter a meeting password to start."),
        ));
      }
    }
  }

//Start Meeting With Random Meeting ID ----- Email & Password For Zoom is required.
  @override
  startMeeting(
    BuildContext context, {
    required String accessToken,
    required String meetingId,
    required String hostEmail,
    Timer? timer,
  }) async {
    await initZAK(accessToken);
    final jwtToken = generateJWT(meetingId, 1);
    ZoomOptions zoomOptions = ZoomOptions(
      domain: "zoom.us",
      appKey: dotenv.env['APP_KEY'], //API KEY FROM ZOOM -- SDK KEY
      appSecret: dotenv.env['APP_SECRET'], //API SECRET FROM ZOOM -- SDK SECRET
      jwtToken: jwtToken,
    );
    var meetingOptions = ZoomMeetingOptions(
      meetingId: meetingId,
      userId: hostEmail,
      displayName: "Username",
      disableDialIn: "false",
      disableDrive: "false",
      disableInvite: "false",
      disableShare: "false",
      zoomAccessToken: zoomAccessTokenZAK,
      zoomToken: zoomAccessTokenZAK,
      disableTitlebar: "false",
      viewOptions: "true",
      noAudio: "false",
      noDisconnectAudio: "false",
      meetingViewOptions: 0,
    );

    var zoom = ZoomView();
    zoom.initZoom(zoomOptions).then((results) {
      if (results[0] == 0) {
        zoom.onMeetingStatus().listen((status) {
          if (kDebugMode) {
            print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
          }
          if (_isMeetingEnded(status[0])) {
            if (kDebugMode) {
              print("[Meeting Status] :- Ended");
            }
            timer?.cancel();
          }
          if (status[0] == "MEETING_STATUS_INMEETING") {
            zoom.meetinDetails().then((meetingDetailsResult) {
              if (kDebugMode) {
                print("[MeetingDetailsResult] :- " +
                    meetingDetailsResult.toString());
              }
            });
          }
        });
        zoom.startMeeting(meetingOptions).then((loginResult) {
          if (kDebugMode) {
            print(
                "[LoginResult] :- " + loginResult[0] + " - " + loginResult[1]);
          }
          if (loginResult[0] == "SDK ERROR") {
            //SDK INIT FAILED
            if (kDebugMode) {
              print((loginResult[1]).toString());
            }
            return;
          } else if (loginResult[0] == "LOGIN ERROR") {
            //LOGIN FAILED - WITH ERROR CODES
            if (kDebugMode) {
              if (loginResult[1] ==
                  ZoomError.ZOOM_AUTH_ERROR_WRONG_ACCOUNTLOCKED) {
                print("Multiple Failed Login Attempts");
              }
              print((loginResult[1]).toString());
            }
            return;
          } else {
            //LOGIN SUCCESS & MEETING STARTED - WITH SUCCESS CODE 200
            if (kDebugMode) {
              print((loginResult[0]).toString());
            }
          }
        }).catchError((error) {
          if (kDebugMode) {
            print("[Error Generated] : " + error);
          }
        });
      }
    }).catchError((error) {
      if (kDebugMode) {
        print("[Error Generated] : " + error);
      }
    });
  }

//Start Meeting With Custom Meeting ID ----- Emila & Password For Zoom is required.
  startMeetingNormal(
    BuildContext context, {
    required String meetingId,
    // required String meetingPassword,
    Timer? timer,
  }) {
    ZoomOptions zoomOptions = ZoomOptions(
      domain: "zoom.us",
      appKey: dotenv.env['APP_KEY'], //API KEY FROM ZOOM -- SDK KEY
      appSecret: dotenv.env['APP_SECRET'], //API SECRET FROM ZOOM -- SDK SECRET
    );
    var meetingOptions = ZoomMeetingOptions(
      meetingId: meetingId,
      // meetingPassword: meetingPassword,
      disableDialIn: "false",
      disableDrive: "false",
      disableInvite: "false",
      disableShare: "false",
      zoomAccessToken: zoomAccessTokenZAK,
      zoomToken: zoomAccessTokenZAK,
      disableTitlebar: "false",
      viewOptions: "true",
      noAudio: "false",
      noDisconnectAudio: "false",
      meetingViewOptions: ZoomMeetingOptions.NO_TEXT_PASSWORD +
          ZoomMeetingOptions.NO_TEXT_MEETING_ID,
    );

    var zoom = ZoomView();
    zoom.initZoom(zoomOptions).then((results) {
      if (results[0] == 0) {
        zoom.onMeetingStatus().listen((status) {
          if (kDebugMode) {
            print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
          }
          if (_isMeetingEnded(status[0])) {
            if (kDebugMode) {
              print("[Meeting Status] :- Ended");
            }
            timer?.cancel();
          }
          if (status[0] == "MEETING_STATUS_INMEETING") {
            zoom.meetinDetails().then((meetingDetailsResult) {
              if (kDebugMode) {
                print("[MeetingDetailsResult] :- " +
                    meetingDetailsResult.toString());
              }
            });
          }
        });
        zoom.startMeetingNormal(meetingOptions).then((loginResult) {
          if (kDebugMode) {
            print("[LoginResult] :- " + loginResult.toString());
          }
          if (loginResult[0] == "SDK ERROR") {
            //SDK INIT FAILED
            if (kDebugMode) {
              print((loginResult[1]).toString());
            }
          } else if (loginResult[0] == "LOGIN ERROR") {
            //LOGIN FAILED - WITH ERROR CODES
            if (kDebugMode) {
              print((loginResult[1]).toString());
            }
          } else {
            //LOGIN SUCCESS & MEETING STARTED - WITH SUCCESS CODE 200
            if (kDebugMode) {
              print((loginResult[0]).toString());
            }
          }
        });
      }
    }).catchError((error) {
      if (kDebugMode) {
        print("[Error Generated] : " + error);
      }
    });
  }
}
