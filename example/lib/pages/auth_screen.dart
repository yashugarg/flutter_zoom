import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:flutter_zoom_example/helpers/auth_provider.dart';



class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.code, super.key});
  final String? code;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    context.read<AuthProvider>().assignCode(widget.code).then((value) {
      Navigator.of(context).pop();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
