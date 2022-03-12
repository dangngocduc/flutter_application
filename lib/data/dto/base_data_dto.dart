import 'package:json_annotation/json_annotation.dart';
part 'base_data_dto.g.dart';

@JsonSerializable(
  genericArgumentFactories: true
)
class BaseDataDto<T> {

  T? data;

  BaseDataDto();

  factory BaseDataDto.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT)
  => _$BaseDataDtoFromJson(json, fromJsonT);

}

