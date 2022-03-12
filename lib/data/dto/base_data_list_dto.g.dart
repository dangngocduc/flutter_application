// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_data_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseDataListDto<T> _$BaseDataListDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) {
  return BaseDataListDto<T>()
    ..data = (json['data'] as List<dynamic>?)?.map(fromJsonT).toList();
}

Map<String, dynamic> _$BaseDataListDtoToJson<T>(
  BaseDataListDto<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': instance.data?.map(toJsonT).toList(),
    };
