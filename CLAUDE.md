# CLAUDE.md - AI Assistant Guide for SamFTP

## Project Overview

SamFTP is a cross-platform FTP media browser and streaming client built with Flutter. It allows users to browse, stream, and download media content from FTP servers with features like bookmarks, playlists, and multiple video player support.

- **Version**: 1.1.0
- **Flutter SDK**: >=3.0.3 <4.0.0
- **Platforms**: Android, iOS, Windows, macOS, Linux, Web

## Quick Start Commands

```bash
# Install dependencies
flutter pub get

# Generate code (routing, DI, freezed)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes during development
flutter pub run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Build release
flutter build apk --release    # Android
flutter build ios --release    # iOS
flutter build windows --release # Windows
flutter build macos --release  # macOS
flutter build linux --release  # Linux
```

## Architecture

This project follows **Clean Architecture** with three main layers:

```
lib/
├── core/                    # Shared functionality
│   ├── error/              # Failure types and exceptions
│   ├── helper/             # Utility functions (http_helper, uri_helper)
│   ├── managers/           # App-wide managers (cache, config, download, bookmark, video_progress)
│   ├── models/             # Shared models (cache_entry)
│   ├── network/            # Network utilities (network_info, retry_interceptor)
│   ├── routes/             # Navigation (auto_route configuration)
│   └── usecase/            # Base use case class
├── di/                      # Dependency injection (GetIt + Injectable)
├── features/                # Feature modules
│   ├── bookmarks/          # Bookmark management
│   ├── folders/            # File/folder browsing
│   ├── home/               # Home screen and content display
│   ├── player/             # Video/audio playback
│   ├── playlists/          # Playlist (M3U) management
│   └── server/             # FTP server configuration
└── main.dart               # App entry point
```

### Feature Module Structure

Each feature follows the same pattern:

```
feature/
├── data/
│   ├── datasources/        # Remote/local data sources
│   ├── models/             # DTOs (*_dto.dart)
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic use cases
└── presentation/
    ├── cubit/              # BLoC/Cubit state management
    ├── pages/              # Screen widgets
    └── widgets/            # Feature-specific widgets
```

## Key Patterns and Conventions

### State Management (BLoC/Cubit)

```dart
@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.getDocument) : super(HomeInitial());

  final GetDocument getDocument;

  void load() async {
    emit(HomeLoading());
    final result = await getDocument(params);
    emit(HomeLoaded(data: result.getOrElse((l) => [])));
  }
}
```

- All Cubits are annotated with `@injectable`
- States are defined in separate `*_state.dart` files using `part`
- States extend `Equatable` for value equality

### Use Cases

```dart
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
```

- Use cases return `Either<Failure, T>` from fpdart
- Use `NoParams` when no parameters are needed

### Error Handling

```dart
abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
}

// Available failure types:
// - ServerFailure(message)
// - NoDataFailure
// - CacheFailure
```

Use `fold()` or `getOrElse()` to handle Either results:

```dart
result.fold(
  (failure) => emit(ErrorState(failure.message)),
  (data) => emit(LoadedState(data)),
);
```

### Dependency Injection

- Uses `get_it` + `injectable` for DI
- Configure dependencies in `lib/di/di.dart`
- Access services via `getIt<ServiceType>()`
- Generated config is in `lib/di/di.config.dart`

### Navigation (auto_route)

- Routes defined in `lib/core/routes/app_routes.dart`
- Generated routes in `lib/core/routes/app_routes.gr.dart`
- Use type-safe navigation with `context.router.push(RouteName())`

## Generated Files

These files are auto-generated and should NOT be manually edited:

- `lib/core/routes/app_routes.gr.dart` - Route generation
- `lib/di/di.config.dart` - DI configuration
- `*.freezed.dart` - Freezed immutable classes (if used)

**Regenerate after changes**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Key Dependencies

### State & Architecture
- `flutter_bloc` - BLoC pattern
- `fpdart` - Functional programming (Either, Option)
- `equatable` - Value equality
- `get_it` + `injectable` - Dependency injection
- `auto_route` - Type-safe routing

### Network
- `dio` - HTTP client
- `internet_connection_checker` - Connectivity monitoring

### Media
- `media_kit` + `video_player` + `chewie` - Video playback
- `external_video_player_launcher` - External player support
- `easy_image_viewer` - Image viewing

### Storage
- `shared_preferences` - Key-value storage
- `flutter_secure_storage` - Encrypted credential storage
- `path_provider` - File system paths

## Development Guidelines

### Code Style

- Follow Flutter/Dart style guide
- Uses `flutter_lints` for linting
- Run `flutter analyze` before committing

### Creating a New Feature

1. Create feature directory under `lib/features/`
2. Add data layer (models, datasources, repositories)
3. Add domain layer (entities, repository interfaces, use cases)
4. Add presentation layer (cubit, states, pages, widgets)
5. Register dependencies with `@injectable` annotations
6. Run code generation
7. Add routes to `app_routes.dart`

### Testing

Tests are located in the `test/` directory mirroring the `lib/` structure:

```
test/
├── features/
│   └── home/
│       └── data/
│           └── datasources/
├── fixtures/          # Test fixtures and readers
└── widget_test.dart
```

Use `mockito` for mocking dependencies.

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **DTOs**: `*_dto.dart`
- **Entities**: `*.dart` (in domain/entities/)
- **Cubits**: `*_cubit.dart`
- **States**: `*_state.dart`
- **Pages**: `*_page.dart`

## CI/CD

### GitHub Actions Release Workflow

Located in `.github/workflows/release.yml`:

- Triggers on push to `main` branch
- Builds signed release APK
- Creates GitHub Release with changelog

**Required Secrets**:
- `KEYSTORE_FILE` - Base64 encoded keystore
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`

See `.github/RELEASE_WORKFLOW_SETUP.md` for setup instructions.

## Important Files

- `pubspec.yaml` - Dependencies and project config
- `analysis_options.yaml` - Linter configuration
- `config.json` - App configuration
- `lib/main.dart` - App entry point with theme configuration
- `lib/core/helper/uri_helper.dart` - FTP URL definitions

## Common Tasks

### Adding a New Screen

1. Create page in `features/<feature>/presentation/pages/`
2. Create cubit/state in `features/<feature>/presentation/cubit/`
3. Add route in `lib/core/routes/app_routes.dart`
4. Run build_runner
5. Navigate using `context.router.push(NewRoute())`

### Adding a New Manager

1. Create manager in `lib/core/managers/`
2. Add `@lazySingleton` or `@singleton` annotation
3. Run build_runner
4. Inject via constructor or access via `getIt<Manager>()`

### Working with Either Types

```dart
// Handling results
final result = await useCase(params);

// Option 1: fold
result.fold(
  (failure) => handleError(failure),
  (success) => handleSuccess(success),
);

// Option 2: getOrElse
final data = result.getOrElse((failure) => defaultValue);

// Option 3: pattern matching
if (result.isRight()) {
  final data = result.getRight().getOrElse(() => throw Exception());
}
```

## Troubleshooting

### Build Runner Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Conflicts

```bash
flutter pub upgrade --major-versions
```

### Platform-Specific Issues

- **Android**: Check `android/app/build.gradle` for minSdk (21)
- **iOS**: Check `ios/Podfile` for platform version
- **Desktop**: Ensure media_kit libs are properly linked

## Notes for AI Assistants

1. **Always run build_runner** after modifying:
   - Route definitions
   - Injectable classes
   - Freezed models

2. **Check imports**: Use relative imports within packages, absolute for cross-package

3. **State immutability**: Cubit states should be immutable using `Equatable`

4. **Error handling**: Always use `Either<Failure, T>` for operations that can fail

5. **DI annotations**:
   - `@injectable` - Standard registration
   - `@lazySingleton` - Singleton, created on first access
   - `@singleton` - Singleton, created immediately

6. **The app uses Material 3** theming with both light and dark modes
