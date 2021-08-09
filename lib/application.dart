import 'package:auth_nav/auth_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/pages/authentication/authentication_navigator.dart';
import 'package:flutter_application/pages/main/main_navigator.dart';
import 'package:flutter_application/pages/splash/app_splash_page.dart';
import 'themes.dart';
class Application extends StatefulWidget {

  const Application({Key? key}) : super(key: key);

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: light(context),
      darkTheme: dark(context),
      home: AuthNavigation(
        //Flow after user login success this page need user NavigatorSupport
        authorizedBuilder: (context) => const MainNavigator(),

        //Flow after user login success
        splashScreen: AppSplashPage(
            (context) async {
              return AuthNavigationState.unAuthorized();
            }
        ),

        //Flow user login success this page need user NavigatorSupport
        unAuthorizedBuilder: (context) => const AuthenticationNavigator(),

        maintenanceBuilder: (context) => Container(),
      ),
    );
  }
}