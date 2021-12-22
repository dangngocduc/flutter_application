import 'package:auth_nav/auth_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/ui/blocs/blocs.dart';
import 'package:flutter_application/ui/pages/pages.dart';
import 'package:get_it/get_it.dart';

import 'data/datasource/local/local_service.dart';
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
        splashScreen: AppSplashPage((context) async {
          if (GetIt.instance.get<LocalService>().isAuthorized()) {
            await GetIt.instance.get<AuthBloc>().initializeApp();
            return AuthNavigationState.authorized();
          } else {
            return AuthNavigationState.unAuthorized();
          }
        }),

        //Flow user login success this page need user NavigatorSupport
        unAuthorizedBuilder: (context) => const AuthenticationNavigator(),

        //Customize if application is have this feature!!
        maintenanceBuilder: (context) => Container(),
      ),
    );
  }
}
