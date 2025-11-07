import 'package:equatable/equatable.dart';

class ClickableModel extends Equatable {
  final String title;
  final String subtitle;
  final String route;
  final bool isFile;

  const ClickableModel({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.isFile,
  });

  // Backwards compatibility getters
  String get name => title;
  String get url => route;
  bool get isFolder => !isFile;
  String? get mimeType => subtitle.isEmpty ? null : subtitle;

  ClickableModel copyWith({
    String? title,
    String? subtitle,
    String? route,
    bool? isFile,
  }) {
    return ClickableModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      route: route ?? this.route,
      isFile: isFile ?? this.isFile,
    );
  }

  @override
  List<Object?> get props => [title, subtitle, route, isFile];
}
