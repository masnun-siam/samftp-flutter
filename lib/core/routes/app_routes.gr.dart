// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:samftp/features/bookmarks/presentation/pages/bookmarks_page.dart'
    as _i1;
import 'package:samftp/features/home/presentation/pages/content_page.dart'
    as _i2;
import 'package:samftp/features/home/presentation/pages/home_page.dart' as _i3;
import 'package:samftp/features/player/presentation/pages/player_page.dart'
    as _i4;

/// generated route for
/// [_i1.BookmarksPage]
class BookmarksRoute extends _i5.PageRouteInfo<void> {
  const BookmarksRoute({List<_i5.PageRouteInfo>? children})
      : super(BookmarksRoute.name, initialChildren: children);

  static const String name = 'BookmarksRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.BookmarksPage();
    },
  );
}

/// generated route for
/// [_i2.ContentPage]
class ContentRoute extends _i5.PageRouteInfo<ContentRouteArgs> {
  ContentRoute({
    _i6.Key? key,
    required String title,
    required String url,
    required String base,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          ContentRoute.name,
          args: ContentRouteArgs(key: key, title: title, url: url, base: base),
          initialChildren: children,
        );

  static const String name = 'ContentRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContentRouteArgs>();
      return _i2.ContentPage(
        key: args.key,
        title: args.title,
        url: args.url,
        base: args.base,
      );
    },
  );
}

class ContentRouteArgs {
  const ContentRouteArgs({
    this.key,
    required this.title,
    required this.url,
    required this.base,
  });

  final _i6.Key? key;

  final String title;

  final String url;

  final String base;

  @override
  String toString() {
    return 'ContentRouteArgs{key: $key, title: $title, url: $url, base: $base}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContentRouteArgs) return false;
    return key == other.key &&
        title == other.title &&
        url == other.url &&
        base == other.base;
  }

  @override
  int get hashCode =>
      key.hashCode ^ title.hashCode ^ url.hashCode ^ base.hashCode;
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.VideoPlayerPage]
class VideoPlayerRoute extends _i5.PageRouteInfo<VideoPlayerRouteArgs> {
  VideoPlayerRoute({
    _i6.Key? key,
    required String url,
    required String title,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          VideoPlayerRoute.name,
          args: VideoPlayerRouteArgs(key: key, url: url, title: title),
          initialChildren: children,
        );

  static const String name = 'VideoPlayerRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VideoPlayerRouteArgs>();
      return _i4.VideoPlayerPage(
        key: args.key,
        url: args.url,
        title: args.title,
      );
    },
  );
}

class VideoPlayerRouteArgs {
  const VideoPlayerRouteArgs({
    this.key,
    required this.url,
    required this.title,
  });

  final _i6.Key? key;

  final String url;

  final String title;

  @override
  String toString() {
    return 'VideoPlayerRouteArgs{key: $key, url: $url, title: $title}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VideoPlayerRouteArgs) return false;
    return key == other.key && url == other.url && title == other.title;
  }

  @override
  int get hashCode => key.hashCode ^ url.hashCode ^ title.hashCode;
}
