import 'package:flutter_application/data/datasources/remote/auth_api_service.dart';
import 'package:flutter_application/data/dto/dto.dart';

class AuthRepository {
  AuthApiService authApiService = AuthApiService();

  Future<AuthenticationDto> login(String userName, String passWord) {
    return authApiService.login(userName, passWord);
  }

  Future logout() {
    return authApiService.logout();
  }

  Future<ProfileDto> profile() {
    return authApiService.profile();
  }
}