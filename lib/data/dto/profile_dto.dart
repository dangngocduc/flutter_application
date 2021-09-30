import 'package:json_annotation/json_annotation.dart';
part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto {
  final String userName;

  ProfileDto(this.userName);

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);
}
