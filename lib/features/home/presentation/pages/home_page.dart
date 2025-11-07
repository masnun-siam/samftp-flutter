import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:samftp/core/helper/uri_helper.dart';
import 'package:samftp/core/routes/app_routes.gr.dart';
import 'package:samftp/features/home/presentation/widgets/app_button.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('SamFtp'),
        ),
        body: Builder(
          builder: (context) {
            return const HomeBody(
                // englishMovies: state.movies,
                // series: state.series,
                // kdramas: state.kdramas,
                // anime: state.anime,
                // animationMovies: state.animation,
                // hindiMovies: state.hindi,
                // southMovies: state.south,
                // banglaMovies: state.bangla,
                // foreignMovies: state.foreign,
                );
          },
        ));
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
    // required this.englishMovies,
    // required this.series,
    // required this.kdramas,
    // required this.anime,
    // required this.animationMovies,
    // required this.hindiMovies,
    // required this.southMovies,
    // required this.banglaMovies,
    // required this.foreignMovies,
  });

  // final List<ClickableModel> englishMovies;
  // final List<ClickableModel> animationMovies;
  // final List<ClickableModel> hindiMovies;
  // final List<ClickableModel> southMovies;
  // final List<ClickableModel> banglaMovies;
  // final List<ClickableModel> series;
  // final List<ClickableModel> kdramas;
  // final List<ClickableModel> anime;
  // final List<ClickableModel> foreignMovies;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = size.width;
      final gridSize = screenWidth > 1200 ? 250
          : screenWidth > 600 ? 200
          : 150;
      return GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: max(size.width ~/ gridSize, 2),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        padding: const EdgeInsets.all(20),
        children: [
          AppButton(
            title: 'English Movies',
            url: SamFtpUrls.movie.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'English Movies',
                  base: SamFtpUrls.movie.base,
                  url: SamFtpUrls.movie.start,
                ),
              );
            },
          ),
          AppButton(
            title: 'Foreign Movies',
            url: SamFtpUrls.foreign.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'Foreign Movies',
                  base: SamFtpUrls.foreign.base,
                  url: SamFtpUrls.foreign.start,
                ),
              );
            },
          ),
          AppButton(
            title: 'Hindi Movies',
            url: SamFtpUrls.hindi.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'Hindi Movies',
                  base: SamFtpUrls.hindi.base,
                  url: SamFtpUrls.hindi.start,
                ),
              );
            },
          ),
          AppButton(
            title: 'Animation Movies',
            url: SamFtpUrls.animation.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'Animation Movies',
                  base: SamFtpUrls.animation.base,
                  url: SamFtpUrls.animation.start,
                ),
              );
            },
          ),
          AppButton(
                  title: 'South Indian Movies',
              url: SamFtpUrls.south.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'South Indian Movies',
                  base: SamFtpUrls.south.base,
                  url: SamFtpUrls.south.start,
                ),
              );
            },
          ),
          AppButton(
                  title: 'Hindi Dubbed Movies',
              url: SamFtpUrls.hindiDubbed.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'Hindi Dubbed Movies',
                  base: SamFtpUrls.hindiDubbed.base,
                  url: SamFtpUrls.hindiDubbed.start,
                ),
              );
            },
          ),
          AppButton(
            title: 'Bangla Movies',
            url: SamFtpUrls.bangla.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'Bangla Movies',
                  base: SamFtpUrls.bangla.base,
                  url: SamFtpUrls.bangla.start,
                ),
              );
            },
          ),
          AppButton(
            title: 'Series',
            url: SamFtpUrls.tv.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'Series',
                  base: SamFtpUrls.tv.base,
                  url: SamFtpUrls.tv.start,
                ),
              );
            },
          ),
          AppButton(
            title: 'KDrama',
            url: SamFtpUrls.kdrama.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'KDrama',
                  base: SamFtpUrls.kdrama.base,
                  url: SamFtpUrls.kdrama.start,
                ),
              );
            },
          ),
          AppButton(
            title: 'Anime',
            url: SamFtpUrls.anime.base,
            onPressed: () {
              context.router.push(
                ContentRoute(
                  title: 'Anime',
                  base: SamFtpUrls.anime.base,
                  url: SamFtpUrls.anime.start,
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
