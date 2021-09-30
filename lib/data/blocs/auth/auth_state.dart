import 'package:flutter_application/data/dto/dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.authorized(ProfileDto profileDto) =
      AuthStateAuthorized;
  const factory AuthState.unAuthorized() = AuthStateUnAuthorized;
}
