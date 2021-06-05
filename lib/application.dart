import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'themes.dart';
class Application extends StatefulWidget {
  static const ROUTE_NAME = 'Application';
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  static const TAG = 'Application';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: light(context),
      darkTheme: dark(context),
    );
  }
}