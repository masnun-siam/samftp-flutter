import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/clickable_model/clickable_model.dart';

part 'clickable_model_dto.freezed.dart';

@freezed
class ClickableModelDto with _$ClickableModelDto {
  const ClickableModelDto._();
  factory ClickableModelDto({
    String? title,
    String? subtitle,
    String? route,
    bool? isFile,
  }) = _ClickableModelDto;

  // to Domain
  ClickableModel toDomain() {
    return ClickableModel(
      title: title ?? '',
      subtitle: subtitle ?? '',
      route: route ?? '',
      isFile: isFile ?? false,
    );
  }
}
