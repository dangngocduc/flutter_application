import 'package:flutter/material.dart';
import 'package:flutter_application/utils/navigator_support.dart';

import '../pages.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  @override
  Widget build(BuildContext context) {
    return NavigatorSupport(
      initialRoute: 'home',
      onGenerateRoute: (setting) {
        return MaterialPageRoute(builder: (context) => const HomePage());
      },
    );
  }
}
