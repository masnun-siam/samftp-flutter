// create the auto route class

import 'package:auto_route/auto_route.dart';

import 'app_routes.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: ContentRoute.page),
        AutoRoute(page: VideoPlayerRoute.page),
        AutoRoute(page: BookmarksRoute.page),
      ];
}
