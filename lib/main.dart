import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_meedu_videoplayer/init_meedu_player.dart';
import 'package:samftp/di/di.dart';
import 'package:samftp/features/home/presentation/cubit/home_cubit.dart';

import 'core/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initMeeduPlayer();

  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return BlocProvider<HomeCubit>(
      create: (context) => getIt<HomeCubit>()..load(),
      child: MaterialApp.router(
        title: 'SamFtp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter.config(),
      ),
    );
  }
}
