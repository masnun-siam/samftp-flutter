import 'package:freezed_annotation/freezed_annotation.dart';

part 'clickable_model.freezed.dart';

@freezed
class ClickableModel with _$ClickableModel {
  factory ClickableModel({
    required String title,
    required String subtitle,
    required String route,
    required bool isFile,
  }) = _ClickableModel;
}
