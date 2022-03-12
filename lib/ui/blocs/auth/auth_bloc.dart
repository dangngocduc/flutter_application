import 'package:auth_nav/auth_nav.dart';
import 'package:flutter_application/data/dto/dto.dart';
import 'package:flutter_application/data/repositories/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:oauth2_dio/oauth2_dio.dart';

import 'auth_state.dart';

class AuthBloc extends Cubit<AuthState> {
  final AuthNavigationBloc authNavigationBloc = GetIt.instance.get();

  final AuthRepository _authRepository = GetIt.instance.get();

  AuthBloc() : super(const AuthState.unAuthorized()) {
    GetIt.instance
        .get<Oauth2Manager<AuthenticationDto>>()
        .controller
        .stream
        .listen((event) {
      if (event != null) {
        authNavigationBloc.emit(AuthNavigationState.authorized());
      } else {
        authNavigationBloc.emit(AuthNavigationState.unAuthorized());
      }
    });
  }

  //Call on splash screen
  Future initializeApp() async {
    final profile = await _authRepository.profile();
    emit(AuthState.authorized(profile));
  }

  Future login(String username, String password) async {
    final auth = await _authRepository.login(username, password);
    GetIt.instance.get<Oauth2Manager<AuthenticationDto>>().add(auth);
    await _authRepository.profile();
  }

  Future logout() async {
    await _authRepository.logout();
    GetIt.instance.get<Oauth2Manager<AuthenticationDto>>().add(null);
  }
}
