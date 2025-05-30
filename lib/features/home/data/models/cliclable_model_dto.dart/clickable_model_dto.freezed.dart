// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clickable_model_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ClickableModelDto {
  String? get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  String? get route => throw _privateConstructorUsedError;
  bool? get isFile => throw _privateConstructorUsedError;

  /// Create a copy of ClickableModelDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClickableModelDtoCopyWith<ClickableModelDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClickableModelDtoCopyWith<$Res> {
  factory $ClickableModelDtoCopyWith(
          ClickableModelDto value, $Res Function(ClickableModelDto) then) =
      _$ClickableModelDtoCopyWithImpl<$Res, ClickableModelDto>;
  @useResult
  $Res call({String? title, String? subtitle, String? route, bool? isFile});
}

/// @nodoc
class _$ClickableModelDtoCopyWithImpl<$Res, $Val extends ClickableModelDto>
    implements $ClickableModelDtoCopyWith<$Res> {
  _$ClickableModelDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClickableModelDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? route = freezed,
    Object? isFile = freezed,
  }) {
    return _then(_value.copyWith(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      route: freezed == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as String?,
      isFile: freezed == isFile
          ? _value.isFile
          : isFile // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClickableModelDtoImplCopyWith<$Res>
    implements $ClickableModelDtoCopyWith<$Res> {
  factory _$$ClickableModelDtoImplCopyWith(_$ClickableModelDtoImpl value,
          $Res Function(_$ClickableModelDtoImpl) then) =
      __$$ClickableModelDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? title, String? subtitle, String? route, bool? isFile});
}

/// @nodoc
class __$$ClickableModelDtoImplCopyWithImpl<$Res>
    extends _$ClickableModelDtoCopyWithImpl<$Res, _$ClickableModelDtoImpl>
    implements _$$ClickableModelDtoImplCopyWith<$Res> {
  __$$ClickableModelDtoImplCopyWithImpl(_$ClickableModelDtoImpl _value,
      $Res Function(_$ClickableModelDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClickableModelDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? route = freezed,
    Object? isFile = freezed,
  }) {
    return _then(_$ClickableModelDtoImpl(
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      route: freezed == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as String?,
      isFile: freezed == isFile
          ? _value.isFile
          : isFile // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$ClickableModelDtoImpl extends _ClickableModelDto {
  _$ClickableModelDtoImpl({this.title, this.subtitle, this.route, this.isFile})
      : super._();

  @override
  final String? title;
  @override
  final String? subtitle;
  @override
  final String? route;
  @override
  final bool? isFile;

  @override
  String toString() {
    return 'ClickableModelDto(title: $title, subtitle: $subtitle, route: $route, isFile: $isFile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClickableModelDtoImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.isFile, isFile) || other.isFile == isFile));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, subtitle, route, isFile);

  /// Create a copy of ClickableModelDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClickableModelDtoImplCopyWith<_$ClickableModelDtoImpl> get copyWith =>
      __$$ClickableModelDtoImplCopyWithImpl<_$ClickableModelDtoImpl>(
          this, _$identity);
}

abstract class _ClickableModelDto extends ClickableModelDto {
  factory _ClickableModelDto(
      {final String? title,
      final String? subtitle,
      final String? route,
      final bool? isFile}) = _$ClickableModelDtoImpl;
  _ClickableModelDto._() : super._();

  @override
  String? get title;
  @override
  String? get subtitle;
  @override
  String? get route;
  @override
  bool? get isFile;

  /// Create a copy of ClickableModelDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClickableModelDtoImplCopyWith<_$ClickableModelDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
