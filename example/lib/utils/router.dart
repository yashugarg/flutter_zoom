import 'package:flutter/material.dart';

import 'package:flutter_zoom_example/pages/auth_screen.dart';
import 'package:flutter_zoom_example/pages/home_screen.dart';
import 'package:flutter_zoom_example/pages/join_meeting_screen.dart';

class Router {
  Router._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/auth') ?? false) {
      final code = settings.name?.split('/auth?code=')[1];
      return MaterialPageRoute(
        builder: (_) => AuthScreen(code: code),
      );
    }
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/join':
        return MaterialPageRoute(builder: (_) => const JoinMeetingScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
