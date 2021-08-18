// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$AuthStateTearOff {
  const _$AuthStateTearOff();

  AuthStateAuthorized authorized(ProfileDto profileDto) {
    return AuthStateAuthorized(
      profileDto,
    );
  }

  AuthStateUnAuthorized unAuthorized() {
    return const AuthStateUnAuthorized();
  }
}

/// @nodoc
const $AuthState = _$AuthStateTearOff();

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfileDto profileDto) authorized,
    required TResult Function() unAuthorized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfileDto profileDto)? authorized,
    TResult Function()? unAuthorized,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStateAuthorized value) authorized,
    required TResult Function(AuthStateUnAuthorized value) unAuthorized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStateAuthorized value)? authorized,
    TResult Function(AuthStateUnAuthorized value)? unAuthorized,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res> implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  final AuthState _value;
  // ignore: unused_field
  final $Res Function(AuthState) _then;
}

/// @nodoc
abstract class $AuthStateAuthorizedCopyWith<$Res> {
  factory $AuthStateAuthorizedCopyWith(
          AuthStateAuthorized value, $Res Function(AuthStateAuthorized) then) =
      _$AuthStateAuthorizedCopyWithImpl<$Res>;
  $Res call({ProfileDto profileDto});
}

/// @nodoc
class _$AuthStateAuthorizedCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateAuthorizedCopyWith<$Res> {
  _$AuthStateAuthorizedCopyWithImpl(
      AuthStateAuthorized _value, $Res Function(AuthStateAuthorized) _then)
      : super(_value, (v) => _then(v as AuthStateAuthorized));

  @override
  AuthStateAuthorized get _value => super._value as AuthStateAuthorized;

  @override
  $Res call({
    Object? profileDto = freezed,
  }) {
    return _then(AuthStateAuthorized(
      profileDto == freezed
          ? _value.profileDto
          : profileDto // ignore: cast_nullable_to_non_nullable
              as ProfileDto,
    ));
  }
}

/// @nodoc

class _$AuthStateAuthorized implements AuthStateAuthorized {
  const _$AuthStateAuthorized(this.profileDto);

  @override
  final ProfileDto profileDto;

  @override
  String toString() {
    return 'AuthState.authorized(profileDto: $profileDto)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is AuthStateAuthorized &&
            (identical(other.profileDto, profileDto) ||
                const DeepCollectionEquality()
                    .equals(other.profileDto, profileDto)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(profileDto);

  @JsonKey(ignore: true)
  @override
  $AuthStateAuthorizedCopyWith<AuthStateAuthorized> get copyWith =>
      _$AuthStateAuthorizedCopyWithImpl<AuthStateAuthorized>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfileDto profileDto) authorized,
    required TResult Function() unAuthorized,
  }) {
    return authorized(profileDto);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfileDto profileDto)? authorized,
    TResult Function()? unAuthorized,
    required TResult orElse(),
  }) {
    if (authorized != null) {
      return authorized(profileDto);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStateAuthorized value) authorized,
    required TResult Function(AuthStateUnAuthorized value) unAuthorized,
  }) {
    return authorized(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStateAuthorized value)? authorized,
    TResult Function(AuthStateUnAuthorized value)? unAuthorized,
    required TResult orElse(),
  }) {
    if (authorized != null) {
      return authorized(this);
    }
    return orElse();
  }
}

abstract class AuthStateAuthorized implements AuthState {
  const factory AuthStateAuthorized(ProfileDto profileDto) =
      _$AuthStateAuthorized;

  ProfileDto get profileDto => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthStateAuthorizedCopyWith<AuthStateAuthorized> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateUnAuthorizedCopyWith<$Res> {
  factory $AuthStateUnAuthorizedCopyWith(AuthStateUnAuthorized value,
          $Res Function(AuthStateUnAuthorized) then) =
      _$AuthStateUnAuthorizedCopyWithImpl<$Res>;
}

/// @nodoc
class _$AuthStateUnAuthorizedCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res>
    implements $AuthStateUnAuthorizedCopyWith<$Res> {
  _$AuthStateUnAuthorizedCopyWithImpl(
      AuthStateUnAuthorized _value, $Res Function(AuthStateUnAuthorized) _then)
      : super(_value, (v) => _then(v as AuthStateUnAuthorized));

  @override
  AuthStateUnAuthorized get _value => super._value as AuthStateUnAuthorized;
}

/// @nodoc

class _$AuthStateUnAuthorized implements AuthStateUnAuthorized {
  const _$AuthStateUnAuthorized();

  @override
  String toString() {
    return 'AuthState.unAuthorized()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is AuthStateUnAuthorized);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfileDto profileDto) authorized,
    required TResult Function() unAuthorized,
  }) {
    return unAuthorized();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfileDto profileDto)? authorized,
    TResult Function()? unAuthorized,
    required TResult orElse(),
  }) {
    if (unAuthorized != null) {
      return unAuthorized();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthStateAuthorized value) authorized,
    required TResult Function(AuthStateUnAuthorized value) unAuthorized,
  }) {
    return unAuthorized(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthStateAuthorized value)? authorized,
    TResult Function(AuthStateUnAuthorized value)? unAuthorized,
    required TResult orElse(),
  }) {
    if (unAuthorized != null) {
      return unAuthorized(this);
    }
    return orElse();
  }
}

abstract class AuthStateUnAuthorized implements AuthState {
  const factory AuthStateUnAuthorized() = _$AuthStateUnAuthorized;
}
