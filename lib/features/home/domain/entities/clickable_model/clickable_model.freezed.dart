// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clickable_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ClickableModel {
  String get title => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  String get route => throw _privateConstructorUsedError;
  bool get isFile => throw _privateConstructorUsedError;

  /// Create a copy of ClickableModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClickableModelCopyWith<ClickableModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClickableModelCopyWith<$Res> {
  factory $ClickableModelCopyWith(
          ClickableModel value, $Res Function(ClickableModel) then) =
      _$ClickableModelCopyWithImpl<$Res, ClickableModel>;
  @useResult
  $Res call({String title, String subtitle, String route, bool isFile});
}

/// @nodoc
class _$ClickableModelCopyWithImpl<$Res, $Val extends ClickableModel>
    implements $ClickableModelCopyWith<$Res> {
  _$ClickableModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClickableModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? subtitle = null,
    Object? route = null,
    Object? isFile = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      route: null == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as String,
      isFile: null == isFile
          ? _value.isFile
          : isFile // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClickableModelImplCopyWith<$Res>
    implements $ClickableModelCopyWith<$Res> {
  factory _$$ClickableModelImplCopyWith(_$ClickableModelImpl value,
          $Res Function(_$ClickableModelImpl) then) =
      __$$ClickableModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String subtitle, String route, bool isFile});
}

/// @nodoc
class __$$ClickableModelImplCopyWithImpl<$Res>
    extends _$ClickableModelCopyWithImpl<$Res, _$ClickableModelImpl>
    implements _$$ClickableModelImplCopyWith<$Res> {
  __$$ClickableModelImplCopyWithImpl(
      _$ClickableModelImpl _value, $Res Function(_$ClickableModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClickableModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? subtitle = null,
    Object? route = null,
    Object? isFile = null,
  }) {
    return _then(_$ClickableModelImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      route: null == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as String,
      isFile: null == isFile
          ? _value.isFile
          : isFile // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ClickableModelImpl implements _ClickableModel {
  _$ClickableModelImpl(
      {required this.title,
      required this.subtitle,
      required this.route,
      required this.isFile});

  @override
  final String title;
  @override
  final String subtitle;
  @override
  final String route;
  @override
  final bool isFile;

  @override
  String toString() {
    return 'ClickableModel(title: $title, subtitle: $subtitle, route: $route, isFile: $isFile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClickableModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.isFile, isFile) || other.isFile == isFile));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, subtitle, route, isFile);

  /// Create a copy of ClickableModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClickableModelImplCopyWith<_$ClickableModelImpl> get copyWith =>
      __$$ClickableModelImplCopyWithImpl<_$ClickableModelImpl>(
          this, _$identity);
}

abstract class _ClickableModel implements ClickableModel {
  factory _ClickableModel(
      {required final String title,
      required final String subtitle,
      required final String route,
      required final bool isFile}) = _$ClickableModelImpl;

  @override
  String get title;
  @override
  String get subtitle;
  @override
  String get route;
  @override
  bool get isFile;

  /// Create a copy of ClickableModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClickableModelImplCopyWith<_$ClickableModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
