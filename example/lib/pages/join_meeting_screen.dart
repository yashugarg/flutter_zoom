import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_zoom_example/helpers/meeting_helper_mobile.dart'
    if (dart.library.html) 'package:flutter_zoom_example/helpers/meeting_helpers_web.dart';

const primary = Color(0xFF0e72ec);

class JoinMeetingScreen extends StatefulWidget {
  const JoinMeetingScreen({super.key});

  @override
  _JoinMeetingScreenState createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  TextEditingController meetingIdController = TextEditingController();
  TextEditingController meetingPasswordController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              "Cancel",
              style: TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        title: const Text(
          "Join a Meeting",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            height: 50,
            decoration: const BoxDecoration(color: Colors.white),
            child: SizedBox(
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: TextField(
                  textAlign: TextAlign.center,
                  cursorColor: primary,
                  controller: meetingIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Meeting ID",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Container(
            height: 50,
            decoration: const BoxDecoration(color: Colors.white),
            child: SizedBox(
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: TextField(
                  textAlign: TextAlign.center,
                  cursorColor: primary,
                  controller: meetingPasswordController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Meeting Password",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Container(
            height: 50,
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                SizedBox(
                  width: size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: TextField(
                      textAlign: TextAlign.center,
                      cursorColor: primary,
                      controller: displayNameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Your Name",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              MeetingHelperSub().joinMeeting(
                context,
                meetingIdController: meetingIdController,
                meetingPasswordController: meetingPasswordController,
                displayNameController: displayNameController,
              );
            },
            child: Container(
              width: size.width * 0.8,
              height: 50,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  "Join",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
