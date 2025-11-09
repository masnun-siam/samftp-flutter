import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:samftp/di/di.dart';
import 'package:samftp/features/home/presentation/cubit/home_cubit.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'core/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  VideoPlayerMediaKit.ensureInitialized(
    android: true,
    iOS: true,
    macOS: true,
    windows: true,
    linux: true,
  );
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
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        routerConfig: appRouter.config(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF8B5CF6),
        tertiary: const Color(0xFFEC4899),
        surface: const Color(0xFFFAFAFA),
        background: const Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1F2937),
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Color(0xFF1F2937),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: Color(0xFF374151),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4B5563),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
        primary: const Color(0xFF818CF8),
        secondary: const Color(0xFFA78BFA),
        tertiary: const Color(0xFFF472B6),
        surface: const Color(0xFF1F2937),
        background: const Color(0xFF111827),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF9FAFB),
        titleTextStyle: TextStyle(
          color: Color(0xFFF9FAFB),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: Color(0xFFF9FAFB),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: Color(0xFFE5E7EB),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFD1D5DB),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
