import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_zoom_example/helpers/auth_provider.dart';
import 'package:flutter_zoom_example/helpers/meeting_helper_mobile.dart'
    if (dart.library.html) 'package:flutter_zoom_example/helpers/meeting_helpers_web.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int activeTab = 0;

  List<Map<String, dynamic>> items = [
    {
      'title': 'Welcome to Zoom',
      'description':
          'Zoom is a free HD meeting app with video and screen sharing for up to 100 people.',
      'img': 'assets/images/image1.jpg'
    },
    {
      'title': 'Join a Meeting',
      'description':
          'Join a meeting with a meeting ID or personal link. You can also join a meeting with a phone number.',
      'img': 'assets/images/image2.jpg'
    },
    {
      'title': 'Host a Meeting',
      'description':
          'Host a meeting with a meeting ID or personal link. You can also host a meeting with a phone number.',
      'img': 'assets/images/image3.jpg'
    },
    {
      'title': 'Start a Meeting',
      'description':
          'Start a meeting with a meeting ID or personal link. You can also start a meeting with a phone number.',
      'img': 'assets/images/image4.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeTab == index
                      ? Colors.black54
                      : const Color(0xffe4e4ed),
                ),
              ),
            );
          }),
        ),
      ),
      body: CarouselSlider(
        options: CarouselOptions(
            viewportFraction: 0.99,
            height: size.height,
            onPageChanged: (int index, _) {
              setState(() {
                activeTab = index;
              });
            }),
        items: List.generate(
          items.length,
          (index) {
            return Container(
              width: size.width,
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(items[index]['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const SizedBox(height: 20),
                      Text(
                        items[index]['description'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                  items[index]['img'] == null
                      ? Container()
                      : Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                items[index]['img'],
                              ),
                            ),
                          ),
                        )
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        width: size.width,
        height: 200,
        decoration: const BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/join');
                },
                child: Container(
                  width: size.width * 0.75,
                  height: 50,
                  decoration: BoxDecoration(
                      color: const Color(0xFF0e72ec),
                      borderRadius: BorderRadius.circular(15)),
                  child: const Center(
                    child: Text(
                      "Join a Meeting",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              authProvider.accessToken == null
                  ? GestureDetector(
                      onTap: () async {
                        final path = ((kIsWeb && kDebugMode)
                                ? "http%3A%2F%2Flocalhost%3A" +
                                    Uri.base.port.toString()
                                : "https%3A%2F%2Fzoom.yashugarg.com") +
                            "%2Fauth";
                        final url = dotenv.env['OAUTH_URL']! + path;
                        if (url != "" && (await canLaunchUrl(Uri.parse(url)))) {
                          launchUrl(
                            Uri.parse(url),
                            webOnlyWindowName: "_self",
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                            color: Color(0xFF0e72ec),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        // try {
                        //   var response = await http.get(
                        //     Uri.parse('https://api.zoom.us/v2/users/me'),
                        //     headers: {
                        //       'Authorization': "Bearer " +
                        //           authProvider.accessToken.toString(),
                        //     },
                        //   );

                        //   if (response.statusCode == 200) {
                        //     var jsonResponse = jsonDecode(response.body);
                        //     print(jsonResponse);
                        //   } else {
                        //     print(
                        //         'Request failed with status: ${response.body}.');
                        //   }
                        // } catch (e) {
                        //   print(e);
                        // }

                        final meetingDetails = await MeetingHelperSub()
                            .createMeeting(authProvider.accessToken!);
                        MeetingHelperSub().startMeeting(
                          context,
                          accessToken: authProvider.accessToken!,
                          meetingId: meetingDetails["id"]!,
                          hostEmail: meetingDetails["host_email"]!,
                        );
                      },
                      child: Container(
                        width: size.width * 0.75,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0e72ec),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "Start a Meeting",
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
        ),
      ),
    );
  }
}
