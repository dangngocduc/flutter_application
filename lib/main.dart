import 'package:auth_nav/auth_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'application.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthNavigationBloc authNavigationBloc = AuthNavigationBloc();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authNavigationBloc)
      ],
      child: const Application(),
    )
  );
}
