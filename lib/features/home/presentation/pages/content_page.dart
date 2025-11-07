import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:samftp/di/di.dart';
import 'package:samftp/features/home/presentation/cubit/content_cubit.dart';
import 'package:samftp/features/home/presentation/widgets/list_item.dart';

import '../../../../core/routes/app_routes.gr.dart';
import '../cubit/content_state.dart';
import 'content_search_deligate.dart';

@RoutePage()
class ContentPage extends StatelessWidget {
  final String url;

  final String title;
  final String base;
  const ContentPage(
      {super.key, required this.title, required this.url, required this.base});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ContentCubit, ContentState>(
      bloc: getIt<ContentCubit>()..load(url),
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: (isDark
                ? const Color(0xFF1F2937)
                : Colors.white).withOpacity(0.7),
            elevation: 0,
            title: Text(
              Uri.decodeFull(url.split('/').last),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            leading: Navigator.canPop(context)
                ? Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05)),
                    ),
                    child: IconButton(
                      style: TextButton.styleFrom(
                        iconColor: isDark ? Colors.white : const Color(0xFF1F2937),
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  )
                : null,
            automaticallyImplyLeading: false,
            actions: [
              if (state is ContentLoaded)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05)),
                  ),
                  child: IconButton(
                    style: TextButton.styleFrom(
                      iconColor: isDark ? Colors.white : const Color(0xFF1F2937),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () {
                      _search(context, state);
                    },
                    icon: const Icon(Icons.search_rounded, size: 20),
                  ),
                ),
            ],
          ),
          body: switch (state) {
            ContentInitial() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A),
                            const Color(0xFF1E293B),
                          ]
                        : [
                            const Color(0xFFF5F5F7),
                            const Color(0xFFEDE9FE),
                          ],
                  ),
                ),
              ),
            ContentLoading() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A),
                            const Color(0xFF1E293B),
                          ]
                        : [
                            const Color(0xFFF5F5F7),
                            const Color(0xFFEDE9FE),
                          ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ContentError() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A),
                            const Color(0xFF1E293B),
                          ]
                        : [
                            const Color(0xFFF5F5F7),
                            const Color(0xFFEDE9FE),
                          ],
                  ),
                ),
                child: Center(
                  child: Text(state.toString()),
                ),
              ),
            ContentLoaded() => Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: state.models.any((element) =>
                        element.route.endsWith('.jpg') ||
                        element.route.endsWith('.png'))
                    ? BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            base +
                                state.models.firstWhere((element) {
                                  final mime =
                                      lookupMimeType(base + element.route);
                                  return mime == 'image/jpeg';
                                }).route,
                          ),
                        ),
                      )
                    : BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  const Color(0xFF0F172A),
                                  const Color(0xFF1E293B),
                                ]
                              : [
                                  const Color(0xFFF5F5F7),
                                  const Color(0xFFEDE9FE),
                                ],
                        ),
                      ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(
                    color: (isDark
                        ? const Color(0xFF0F172A)
                        : Colors.white).withOpacity(0.3),
                    child: ListView.separated(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                        bottom: 20,
                      ),
                      itemBuilder: (context, index) {
                        return ListItem(
                          model: state.models[index],
                          base: base,
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: state.models.length,
                    ),
                  ),
                ),
              ),
          },
        );
      },
    );
  }

  Future _search(BuildContext context, ContentLoaded state) async {
    return showSearch(
      context: context,
      delegate: ContentSearchDelegate(state.models),
    ).then((value) {
      if (value != null) {
        final model = value;
        if (!model.isFile) {
          ContentRoute(
            title: Uri.decodeFull(model.route.split('/').last),
            base: base,
            url: base + model.route,
            // ignore: use_build_context_synchronously
          ).push(context);
        } else {
          // play video
          final url = base + model.route;
          print(url);
          // Share.share(url);
          // context.router.push(
          //   VideoPlayerRoute(
          //     url: url,
          //     title: Uri.decodeFull(model.route.split('/').last),
          //   ),
          // );
        }
      }
    });
  }
}

class SearchAction extends Action<SearchIntent> {
  @override
  Object? invoke(SearchIntent intent) {
    return intent.search;
  }
}

class SearchIntent extends Intent {
  final Function(BuildContext, ContentLoaded) search;
  const SearchIntent({
    required this.search,
  });
}
