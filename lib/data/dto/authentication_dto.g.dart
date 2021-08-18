// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthenticationDto _$AuthenticationDtoFromJson(Map<String, dynamic> json) {
  return AuthenticationDto(
    json['accessToken'] as String,
    json['refreshToken'] as String,
  );
}

Map<String, dynamic> _$AuthenticationDtoToJson(AuthenticationDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
