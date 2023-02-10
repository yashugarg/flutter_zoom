import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_zoom_example/utils/router.dart' as router;
import 'package:flutter_zoom_example/helpers/auth_provider.dart';
import './helpers/config_url_strategy/noweb.dart'
    if (dart.library.html) './helpers/config_url_strategy/web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  configureApp();
  runApp(
    ChangeNotifierProvider<AuthProvider>(
      lazy: false,
      create: (context) => AuthProvider(sharedPreferences),
      builder: (context, child) => const ExampleApp(),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example Zoom SDK',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: const [],
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: router.Router.generateRoute,
    );
  }
}
