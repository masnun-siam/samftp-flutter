import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samftp/di/di.dart';
import 'package:samftp/features/home/presentation/cubit/content_cubit.dart';
import 'package:samftp/features/home/presentation/widgets/list_item.dart';

import '../../../../core/routes/app_routes.gr.dart';
import '../cubit/content_state.dart';
import 'content_search_deligate.dart';

@RoutePage()
class ContentPage extends StatelessWidget {
  const ContentPage(
      {super.key, required this.title, required this.url, required this.base});

  final String url;
  final String title;
  final String base;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ContentCubit, ContentState>(
        bloc: getIt<ContentCubit>()..load(url),
        builder: (context, state) {
          return switch (state) {
            ContentInitial() => Container(),
            ContentLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ContentError() => Center(
                child: Text(state.toString()),
              ),
            ContentLoaded() => Scaffold(
                appBar: AppBar(
                  title: Text(Uri.decodeFull(url.split('/').last)),
                  actions: [
                    IconButton(
                      onPressed: () {
                        _search(context, state);
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                body: ListView.separated(
                  padding: const EdgeInsets.all(20),
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
          };
        },
      ),
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
          context.router.push(
            ContentRoute(
              title: Uri.decodeFull(model.route.split('/').last),
              base: base,
              url: base + model.route,
            ),
          );
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

class SearchIntent extends Intent {
  final Function(BuildContext, ContentLoaded) search;
  const SearchIntent({
    required this.search,
  });
}

class SearchAction extends Action<SearchIntent> {
  @override
  Object? invoke(SearchIntent intent) {
    return intent.search;
  }
}
