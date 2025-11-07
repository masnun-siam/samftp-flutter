import '../../../domain/entities/clickable_model/clickable_model.dart';

class ClickableModelDto {
  final String? title;
  final String? subtitle;
  final String? route;
  final bool? isFile;

  const ClickableModelDto({
    this.title,
    this.subtitle,
    this.route,
    this.isFile,
  });

  ClickableModel toDomain() {
    return ClickableModel(
      title: title ?? '',
      subtitle: subtitle ?? '',
      route: route ?? '',
      isFile: isFile ?? false,
    );
  }
}
