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
    return BlocBuilder<ContentCubit, ContentState>(
      bloc: getIt<ContentCubit>()..load(url),
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            backgroundColor: Colors.white.withValues(alpha: .5),
            elevation: 0,
            title: Text(Uri.decodeFull(url.split('/').last)),
            leading: Navigator.canPop(context)
                ? ClipOval(
                    child: IconButton(
                      style: TextButton.styleFrom(
                        iconColor: Colors.black,
                        padding: const EdgeInsets.all(16),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  )
                : null,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            actions: [
              if (state is ContentLoaded)
                IconButton(
                  style: TextButton.styleFrom(
                    iconColor: Colors.black,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {
                    _search(context, state);
                  },
                  icon: const Icon(Icons.search),
                ),
            ],
          ),
          body: switch (state) {
            ContentInitial() => Container(),
            ContentLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ContentError() => Center(
                child: Text(state.toString()),
              ),
            ContentLoaded() => Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: kToolbarHeight),
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
                    : null,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      return ListItem(
                        model: state.models[index],
                        base: base,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: state.models.length,
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
