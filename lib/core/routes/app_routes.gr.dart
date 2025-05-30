// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:flutter/material.dart' as _i5;
import 'package:samftp/features/home/presentation/pages/content_page.dart'
    as _i1;
import 'package:samftp/features/home/presentation/pages/home_page.dart' as _i2;
import 'package:samftp/features/player/presentation/pages/player_page.dart'
    as _i3;

/// generated route for
/// [_i1.ContentPage]
class ContentRoute extends _i4.PageRouteInfo<ContentRouteArgs> {
  ContentRoute({
    _i5.Key? key,
    required String title,
    required String url,
    required String base,
    List<_i4.PageRouteInfo>? children,
  }) : super(
          ContentRoute.name,
          args: ContentRouteArgs(
            key: key,
            title: title,
            url: url,
            base: base,
          ),
          initialChildren: children,
        );

  static const String name = 'ContentRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContentRouteArgs>();
      return _i1.ContentPage(
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

  final _i5.Key? key;

  final String title;

  final String url;

  final String base;

  @override
  String toString() {
    return 'ContentRouteArgs{key: $key, title: $title, url: $url, base: $base}';
  }
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i4.PageRouteInfo<void> {
  const HomeRoute({List<_i4.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.VideoPlayerPage]
class VideoPlayerRoute extends _i4.PageRouteInfo<VideoPlayerRouteArgs> {
  VideoPlayerRoute({
    _i5.Key? key,
    required String url,
    required String title,
    List<_i4.PageRouteInfo>? children,
  }) : super(
          VideoPlayerRoute.name,
          args: VideoPlayerRouteArgs(
            key: key,
            url: url,
            title: title,
          ),
          initialChildren: children,
        );

  static const String name = 'VideoPlayerRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VideoPlayerRouteArgs>();
      return _i3.VideoPlayerPage(
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

  final _i5.Key? key;

  final String url;

  final String title;

  @override
  String toString() {
    return 'VideoPlayerRouteArgs{key: $key, url: $url, title: $title}';
  }
}
