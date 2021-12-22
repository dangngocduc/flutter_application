import 'package:auth_nav/auth_nav.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application/ui/blocs/blocs.dart';
import 'package:get_it/get_it.dart';
import 'package:oauth2_dio/oauth2_dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasource/local/local_service.dart';
import 'data/dto/dto.dart';
import 'data/repositories/repositories.dart';
import 'env.dart';

Future initializeDependencies() async {
  Dio dio = Dio(BaseOptions(baseUrl: baseURL));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  GetIt.instance.registerSingleton(dio);

  GetIt.instance.registerSingleton(AuthRepository());

  //region Local Service
  GetIt.instance.registerSingleton(await SharedPreferences.getInstance());

  GetIt.instance.registerSingleton(LocalService());
  //endregion

  //region OAuth Manager
  Oauth2Manager<AuthenticationDto> _oauth2manager = Oauth2Manager<
          AuthenticationDto>(
      currentValue: GetIt.instance.get<LocalService>().getAuthenticationDto(),
      onSave: (value) {
        GetIt.instance.get<LocalService>().saveAuth(value as AuthenticationDto);
      });

  GetIt.instance
      .registerSingleton<Oauth2Manager<AuthenticationDto>>(_oauth2manager);

  dio.interceptors.add(
    Oauth2Interceptor(
      dio: GetIt.instance.get<Dio>(),
      oauth2Dio: Dio(BaseOptions(baseUrl: dio.options.baseUrl)),
      pathRefreshToken: 'auth/refresh-token',
      parserJson: (json) {
        return AuthenticationDto.fromJson(json as Map<String, dynamic>);
      },
      tokenProvider: _oauth2manager,
    ),
  );
  //endregion

  GetIt.instance.registerSingleton(AuthNavigationBloc());

  GetIt.instance.registerSingleton(AuthBloc());
}
