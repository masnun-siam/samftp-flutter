# SamFTP Flutter

A cross-platform Flutter application for browsing, streaming, and downloading media from SAM-FTP servers. Built with clean architecture principles, modern state management, and comprehensive feature support across Android, iOS, Windows, macOS, Linux, and Web platforms.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Configuration](#configuration)
- [Building & Deployment](#building--deployment)
- [Testing](#testing)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Overview

**SamFTP** is a feature-rich media browsing and streaming client designed to work with SAM-FTP servers. It's a complete Flutter migration from the original Python CLI application, providing a modern native experience on multiple platforms while maintaining backward compatibility with SAM-FTP server protocols.

### Key Benefits

- **Cross-Platform**: Single codebase for mobile, tablet, and desktop
- **High Performance**: Intelligent caching with TTL-based expiration
- **User-Friendly**: Responsive design with Material Design 3
- **Secure**: Encrypted credential storage with multi-server support
- **Automated Releases**: CI/CD pipeline for APK builds and GitHub releases
- **Modern Architecture**: Clean architecture with Flutter BLoC pattern

## Features

### Core Features

#### 🎬 Media Streaming & Playback
- **Video Streaming**: Full-featured video player with Chewie UI
- **Audio Support**: Integrated audio playback capabilities
- **Image Viewing**: Easy-to-use image viewer with zoom support
- **Multiple Player Options**: Support for external video players (e.g., MX Player on Android)
- **Adaptive Quality**: Streaming compatible with various server bandwidths

#### 📁 File Management
- **Directory Browsing**: Intuitive navigation through SAM-FTP server directories
- **Multi-Select**: Select multiple files for batch operations
- **File Search**: Fuzzy string matching for quick content discovery
- **Download Manager**: Single and batch downloads with progress tracking
- **File Info**: Display file metadata including MIME types and sizes

#### 🔖 Bookmarking System
- **Save Favorites**: Quick bookmarking of frequently accessed directories
- **Server Grouping**: Organize bookmarks by server
- **Quick Access**: Jump to bookmarked locations in one tap
- **Persistent Storage**: JSON-based bookmark storage with import/export

#### 🎵 Playlist Management
- **Playlist Creation**: Build custom playlists from browsed content
- **M3U Generation**: Generate standard M3U playlist files
- **Playlist Actions**: Save, load, and manage multiple playlists
- **Format Support**: Compatible with standard media player playlists

#### 🖥️ Multi-Server Support
- **Multiple Connections**: Manage and browse multiple SAM-FTP servers
- **Secure Storage**: Encrypted credential storage using flutter_secure_storage
- **HTTP Basic Auth**: Automatic authentication header generation
- **Connection Status**: Real-time connectivity checking with automatic retry

#### 🎨 User Interface
- **Responsive Design**: Adapts seamlessly to phones, tablets, and desktop screens
- **Dark/Light Themes**: Full Material Design 3 theme support
- **Adaptive Layouts**: Column and multi-column layouts based on screen size
- **Touch Optimized**: Large touch targets and intuitive gestures

#### 🔍 Advanced Caching
- **Two-Tier Caching**: Memory cache for speed + disk cache for persistence
- **TTL Expiration**: Configurable cache expiration (default: 5 minutes)
- **Smart Invalidation**: Automatic cleanup of expired entries
- **SHA256 Hashing**: Secure cache key generation from URLs

#### 📊 Logging & Debugging
- **Centralized Logging**: Unified logging system across the application
- **File-Based Logs**: Persistent log storage for troubleshooting
- **Log Levels**: Debug, info, warning, and error logging
- **Performance Metrics**: Timing information for cache operations

#### 🔄 Network Features
- **Automatic Retry**: Exponential backoff retry logic (1s, 2s, 4s)
- **Connectivity Detection**: Real-time network status checking
- **Timeout Handling**: Graceful handling of network timeouts
- **Error Recovery**: Comprehensive error handling with user feedback

#### 📤 Content Sharing
- **Native Share**: Share files and links via native sharing mechanisms
- **Social Integration**: Direct sharing to messaging and social apps
- **URL Sharing**: Generate shareable links for content

## Screenshots

*(Screenshots would be added here)*

## Prerequisites

### System Requirements

- **Flutter SDK**: Version 3.24.0 or later
- **Dart SDK**: Version 3.0.3 or later
- **Java**: JDK 11+ for Android builds
- **Android SDK**: API level 21 (Android 5.0) minimum
- **Xcode**: Version 12+ for iOS development (macOS only)
- **Visual Studio**: For Windows desktop builds

### Development Environment

```bash
# Check Flutter installation
flutter --version

# Check Dart installation
dart --version

# Check if all dependencies are met
flutter doctor
```

## Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd samftp-flutter
```

### 2. Install Dependencies

```bash
# Get all dependencies
flutter pub get

# Update to latest compatible versions
flutter pub upgrade
```

### 3. Generate Code

The project uses code generation for routing, dependency injection, and data models:

```bash
# Generate all code (routing, DI, freezed models)
dart run build_runner build

# Clean and regenerate if needed
dart run build_runner clean
dart run build_runner build
```

### 4. Generate App Icons

```bash
dart run flutter_launcher_icons
```

### 5. Run the Application

```bash
# Run on default device/emulator
flutter run

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device-id>

# Run with verbose output
flutter run -v

# Run in release mode
flutter run --release
```

## Project Structure

```
lib/
├── main.dart                           # Application entry point & initialization
├── core/                               # Shared core layer
│   ├── error/                          # Exception & failure handling
│   │   ├── exceptions.dart            # Custom exception classes
│   │   └── failure.dart               # Failure objects for error handling
│   ├── helper/                         # Helper utilities
│   │   ├── http_helper.dart           # HTTP requests with Dio & interceptors
│   │   └── uri_helper.dart            # URI manipulation utilities
│   ├── managers/                       # Business logic managers
│   │   ├── app_logger.dart            # Centralized logging system
│   │   ├── cache_manager.dart         # TTL-based caching (memory + disk)
│   │   ├── bookmark_manager.dart      # Bookmark CRUD operations
│   │   ├── config_manager.dart        # Server & app configuration
│   │   └── download_manager.dart      # File download with progress tracking
│   ├── models/                         # Core data models
│   │   └── cache_entry.dart           # Cache entry model
│   ├── network/                        # Network layer
│   │   ├── network_info.dart          # Connectivity checking
│   │   └── retry_interceptor.dart     # Exponential backoff retry logic
│   ├── routes/                         # Navigation & routing
│   │   ├── app_routes.dart            # AutoRoute configuration
│   │   └── app_routes.gr.dart         # Generated routes (auto-generated)
│   ├── usecase/                        # Abstract use case patterns
│   │   ├── usecase.dart               # Base use case class
│   │   └── get_base_url.dart          # Base URL use case
│   └── core.dart                       # Barrel export file
│
├── features/                           # Feature modules (clean architecture)
│   ├── home/                          # Home & category browsing feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── datasource.dart   # HTTP requests & HTML parsing
│   │   │   ├── models/
│   │   │   │   └── clickable_model_dto.dart  # Data transfer object
│   │   │   └── repositories/
│   │   │       └── repo_impl.dart    # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── clickable_model/  # File/folder representation
│   │   │   ├── repositories/
│   │   │   │   └── repository.dart   # Abstract repository
│   │   │   └── usecases/
│   │   │       └── get_document.dart # Use case for fetching content
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── home_cubit.dart   # Home screen state management
│   │       │   ├── home_state.dart   # Home screen states
│   │       │   ├── content_cubit.dart # Content browsing state
│   │       │   └── content_state.dart # Content states
│   │       ├── pages/
│   │       │   ├── home_page.dart    # Landing page with categories
│   │       │   └── content_page.dart # Directory/folder browsing
│   │       └── widgets/
│   │           ├── app_button.dart    # Reusable button component
│   │           ├── list_item.dart     # Content list item widget
│   │           └── content_search_delegate.dart # Search UI
│   │
│   ├── player/                        # Media player feature
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── player_cubit.dart  # Player state management
│   │       │   └── player_state.dart  # Player states
│   │       └── pages/
│   │           └── player_page.dart   # Video player with Chewie UI
│   │
│   ├── playlists/                     # Playlist management feature
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── m3u_generator.dart # M3U playlist generation
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── playlist_item.dart # Playlist item model
│   │   └── presentation/
│   │       └── cubit/
│   │           ├── playlist_cubit.dart # Playlist management state
│   │           └── playlist_state.dart # Playlist states
│   │
│   ├── server/                        # Server configuration feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── server_dto.dart    # Server data transfer object
│   │   └── domain/
│   │       └── entities/
│   │           └── server.dart        # Server entity with auth
│   │
│   ├── bookmarks/                     # Bookmarks feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── bookmark_dto.dart  # Bookmark data model
│   │   └── domain/
│   │       └── entities/
│   │           └── bookmark.dart      # Bookmark entity
│   │
│   └── folders/                       # Folder management feature
│       └── presentation/
│           └── cubit/
│               ├── folders_cubit.dart # Folder state management
│               └── folders_state.dart # Folder states
│
├── di/                                # Dependency Injection
│   ├── di.dart                        # GetIt configuration
│   └── di.config.dart                 # Generated DI configuration (auto-generated)
│
├── config.json                        # Module generation configuration
└── assets/                            # Static assets
    └── images/
        └── samftp.jpg                 # App icon source
```

### Features Directory Details

Each feature follows the **Clean Architecture** pattern with three distinct layers:

#### Data Layer (`/data`)
- **Models**: Data transfer objects (DTOs) for serialization
- **Datasources**: Remote (API/HTTP) and local data sources
- **Repositories**: Implementations of domain repositories

#### Domain Layer (`/domain`)
- **Entities**: Pure Dart classes representing business logic objects
- **Repositories**: Abstract repository interfaces
- **Usecases**: Business logic encapsulation

#### Presentation Layer (`/presentation`)
- **Cubits**: State management using BLoC pattern
- **Pages**: Full-screen UI components
- **Widgets**: Reusable UI components

## Architecture

### Design Patterns Used

#### 1. Clean Architecture
The application separates concerns into three distinct layers:

```
Presentation Layer (UI)
         ↓
Business Logic Layer (State Management via Cubit)
         ↓
Domain Layer (Business Rules & Entities)
         ↓
Data Layer (External Sources)
```

#### 2. Repository Pattern
- Abstract repositories in domain layer
- Concrete implementations in data layer
- Abstraction enables easy testing and switching implementations

#### 3. Dependency Injection
- **GetIt**: Service locator for managing dependencies
- **Injectable**: Code generation for DI configuration
- Lazy singletons and factory patterns for optimal resource usage

#### 4. State Management with BLoC
- **Cubit**: Simplified BLoC variant (no events, only functions)
- **Equatable**: Value equality for state comparison
- **Immutable states**: Using Freezed for immutable data classes

#### 5. Error Handling
- **Custom Exceptions**: Domain-specific exception types
- **Failure Objects**: FPDart Either<Failure, Success> pattern
- **Centralized Handling**: Consistent error handling across the app

### Data Flow Example

```
User Action
    ↓
Presentation Layer (Page/Widget)
    ↓
Cubit (State Management)
    ↓
Domain Layer (Use Case)
    ↓
Repository (Data Layer Interface)
    ↓
Data Source (HTTP/Local)
    ↓
External API (SAM-FTP Server)
```

## Configuration

### 1. Environment Setup

```bash
# Flutter version management
flutter version # Check current version
flutter downgrade # Downgrade to specific version if needed

# Ensure Flutter is on the correct channel
flutter channel stable
flutter upgrade
```

### 2. Android Configuration

**Location**: `android/app/build.gradle`

```gradle
defaultConfig {
    applicationId = "com.msiamn.samftp"
    minSdkVersion 21  // Android 5.0+
    targetSdkVersion 33
    versionCode 1
    versionName "1.0.0"
}
```

### 3. iOS Configuration

**Location**: `ios/Podfile` and `ios/Runner.xcodeproj`

```ruby
platform :ios, '11.0'
```

**Requirements for Building**:
- Xcode 12+
- iOS Deployment Target: 11.0+
- iOS Signing Certificate

### 4. Creating Server Configurations

Server configurations are managed through the **Server entity** with secure credential storage:

```dart
Server(
  name: 'My Server',
  url: 'http://example.com/ftp',
  username: 'user@example.com',
  password: 'secure_password', // Stored encrypted
  lastAccessedTime: DateTime.now(),
  preferredPlayer: 'default', // or external player package name
)
```

### 5. Caching Configuration

The **CacheManager** provides TTL-based caching:

```dart
// Default: 5 minutes TTL
// Configurable per request or globally
CacheManager.getInstance().cache<T>(
  key: url,
  fetcher: () => httpFetch(url),
  ttlMinutes: 5, // Custom TTL
)
```

### 6. Application Initialization

**Location**: `lib/main.dart`

```dart
void main() async {
  // Initialize video player for all platforms
  await VideoPlayerMediaKit.ensureInitialized();

  // Configure dependency injection
  configureDependencies();

  // Initialize app logger
  AppLogger.initialize();

  runApp(const MyApp());
}
```

### 7. Logging Configuration

**Location**: `core/managers/app_logger.dart`

```dart
// Centralized logging system
AppLogger.debug('Debug message');
AppLogger.info('Info message');
AppLogger.warning('Warning message');
AppLogger.error('Error message', exception, stackTrace);

// Logs are written to: Application Documents Directory/logs/
```

## Building & Deployment

### 1. Android APK Build

#### Manual Build
```bash
# Development build
flutter build apk --debug

# Release build with signing
flutter build apk --release
```

#### Automated Release (GitHub Actions)

The project includes a CI/CD pipeline (`.github/workflows/release.yml`) that:

1. **Validates Secrets**
   - Checks for KEYSTORE_FILE, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD

2. **Sets Up Environment**
   - Java 17 (Zulu distribution)
   - Flutter 3.24.0
   - Gradle caching

3. **Builds APK**
   - Decodes base64 keystore
   - Creates key.properties
   - Builds release APK

4. **Creates Release**
   - Extracts version from pubspec.yaml
   - Generates Git tag (v1.0.0)
   - Creates changelog from commits
   - Uploads APK to GitHub Releases

### 2. Release Setup (One-Time)

```bash
# 1. Create a keystore
keytool -genkey -v \
  -keystore ~/key.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias key

# 2. Encode to base64
base64 ~/key.jks > key.txt

# 3. Add GitHub Secrets
# Go to: Repository Settings → Secrets → New repository secret
# Add:
# - KEYSTORE_FILE (base64 encoded keystore)
# - KEYSTORE_PASSWORD
# - KEY_ALIAS
# - KEY_PASSWORD
```

### 3. Web Build

```bash
# Build web version
flutter build web

# Serve locally for testing
flutter run -d web-server

# Output location: build/web/
```

### 4. Desktop Builds

#### Windows
```bash
flutter build windows
# Output: build/windows/runner/Release/

# Install
flutter install -d windows
```

#### macOS
```bash
flutter build macos
# Output: build/macos/Build/Products/Release/
```

#### Linux
```bash
flutter build linux
# Output: build/linux/x64/release/bundle/
```

### 5. iOS Build

```bash
# Requires macOS with Xcode
flutter build ios

# Create IPA for distribution
flutter build ipa

# Upload to TestFlight or App Store via Xcode
open ios/Runner.xcworkspace
```

### 6. Version Management

**Location**: `pubspec.yaml`

```yaml
version: 1.0.0+1
# Format: semantic_version+build_number
# Example: 1.2.3+45
```

Update version before releases:
```bash
# In pubspec.yaml
version: 1.0.1+2
```

## Testing

### Test Structure

```
test/
├── fixtures/
│   └── fixture_reader.dart          # Test data loading utilities
├── features/
│   └── home/
│       └── data/
│           └── datasources/
│               └── datasource_test.dart  # HTML parsing tests
└── widget_test.dart                 # App initialization smoke test
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/home/data/datasources/datasource_test.dart

# Run tests matching pattern
flutter test -k "datasource"

# Watch mode (re-run on changes)
flutter test --watch

# Generate coverage report
flutter test --coverage
# Install lcov: brew install lcov (macOS) or apt-get install lcov (Linux)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Examples

#### Widget Test
```dart
void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

#### Unit Test with Mocking
```dart
void main() {
  late MockDatasource mockDatasource;
  late HomeCubit homeCubit;

  setUp(() {
    mockDatasource = MockDatasource();
    homeCubit = HomeCubit(mockDatasource);
  });

  test('Fetch content returns data', () async {
    when(mockDatasource.getContent(any))
      .thenAnswer((_) async => testData);

    await homeCubit.fetchContent('url');

    expect(homeCubit.state, isA<ContentLoaded>());
  });
}
```

### Current Test Coverage

- **Datasource Tests**: HTML parsing and content extraction
- **Widget Tests**: App initialization and basic UI rendering
- **Mocking**: Using Mockito for dependency mocking

## Dependencies

### State Management & Architecture
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | Cubit-based state management |
| `equatable` | ^2.0.5 | Value equality implementation |
| `get_it` | ^8.0.3 | Service locator/DI |
| `injectable` | ^2.1.2 | DI code generation |
| `fpdart` | ^1.1.0 | Functional programming (Either, Task) |

### Network & Connectivity
| Package | Version | Purpose |
|---------|---------|---------|
| `dio` | ^5.7.0 | HTTP client with interceptors |
| `internet_connection_checker` | ^3.0.1 | Check network connectivity |
| `dart_ping` | ^9.0.0 | Ping for network diagnostics |

### Storage & Persistence
| Package | Version | Purpose |
|---------|---------|---------|
| `shared_preferences` | ^2.1.2 | App preferences (key-value) |
| `flutter_secure_storage` | ^9.0.0 | Encrypted credential storage |
| `path_provider` | ^2.1.1 | Platform-specific file paths |

### Media & Video
| Package | Version | Purpose |
|---------|---------|---------|
| `video_player` | ^2.9.5 | Native video player |
| `chewie` | ^1.11.3 | Video player UI wrapper |
| `video_player_media_kit` | git | Cross-platform media kit |
| `media_kit_libs_*` | git | Platform-specific media libraries |

### Content & Parsing
| Package | Version | Purpose |
|---------|---------|---------|
| `html` | ^0.15.4 | HTML parsing (DOM manipulation) |
| `html_character_entities` | ^1.0.0+1 | HTML entity decoding |
| `string_similarity` | ^2.0.0 | Fuzzy string matching for search |
| `mime` | ^2.0.0 | MIME type detection |

### Routing & Navigation
| Package | Version | Purpose |
|---------|---------|---------|
| `auto_route` | ^10.2.0 | Declarative routing |
| `freezed_annotation` | ^3.0.0 | Immutable data classes |

### UI & UX
| Package | Version | Purpose |
|---------|---------|---------|
| `easy_image_viewer` | ^1.2.1 | Image viewing gallery |
| `responsive_framework` | ^1.5.0 | Responsive design utilities |
| `auto_size_text` | ^3.0.0 | Responsive text sizing |
| `share_plus` | ^11.0.0 | Native sharing functionality |

### Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| `intl` | ^0.18.1 | Date/time formatting & i18n |
| `logger` | ^2.0.2 | Enhanced logging library |
| `crypto` | ^3.0.3 | SHA256 hashing for cache keys |

### Development Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Testing framework |
| `mockito` | ^5.4.2 | Mocking for tests |
| `build_runner` | ^2.6.0 | Code generation runner |
| `auto_route_generator` | ^10.2.0 | Route code generation |
| `freezed` | ^3.0.6 | Immutable class generation |
| `injectable_generator` | ^2.7.0 | DI code generation |
| `flutter_launcher_icons` | ^0.14.4 | App icon generation |
| `flutter_lints` | ^6.0.0 | Dart linting rules |

## Contributing

### Development Workflow

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Follow Dart/Flutter conventions
   - Adhere to clean architecture principles
   - Add appropriate tests

3. **Generate Code**
   ```bash
   dart run build_runner build
   ```

4. **Run Tests**
   ```bash
   flutter test
   ```

5. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: Add your feature description"
   ```

6. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use immutable objects with Freezed

### Architecture Guidelines

- **Don't skip layers**: Always use repository pattern
- **Keep domain logic**: Domain layer should have zero dependencies on external packages
- **Immutable states**: Use Freezed for state classes
- **Error handling**: Use custom exceptions and failure objects
- **Testing**: Write tests for business logic and datasources

## Troubleshooting

### Common Issues & Solutions

#### 1. Build Runner Not Generating Code

```bash
# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# Or use watch mode
dart run build_runner watch
```

#### 2. Dependencies Conflicts

```bash
# Update pubspec.lock
flutter pub get

# If still issues, clean everything
flutter clean
flutter pub get
dart run build_runner build
```

#### 3. Android Build Fails

```bash
# Check Gradle version and compatibility
./gradlew --version

# Clean Gradle
cd android
./gradlew clean
cd ..

# Rebuild
flutter build apk --release
```

#### 4. App Crashes on Startup

1. Check `main.dart` initialization order
2. Verify all DI providers are registered
3. Check logcat for error messages:
   ```bash
   flutter logs
   ```

#### 5. Network Requests Timeout

- Check server URL is accessible
- Verify internet connection
- Check firewall rules
- Increase timeout in `http_helper.dart`

#### 6. Video Player Not Loading

```bash
# Ensure media kit is initialized
await VideoPlayerMediaKit.ensureInitialized();

# Check MediaKit platform plugins
flutter pub get
dart run build_runner build
```

#### 7. Cache Issues

```dart
// Clear all cache
await CacheManager.getInstance().clearCache();

// Clear disk cache
await CacheManager.getInstance().clearDiskCache();
```

### Debug Mode

```bash
# Enable verbose logging
flutter run -v

# Verbose build
flutter build apk --release -v

# Debug dart code
flutter run --debug

# Use Dart DevTools
flutter pub global activate devtools
devtools
```

### Enable Enhanced Logging

```dart
// In your Cubit or page
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

## Advanced Features

### Custom Cache Configuration

```dart
// Configure cache per request
final data = await CacheManager.getInstance().cache<List<Item>>(
  key: 'custom_cache_key',
  fetcher: () => fetchFromServer(),
  ttlMinutes: 10, // Custom TTL
);
```

### Extend Player Capabilities

```dart
// In player_page.dart, extend player with custom controls
class CustomPlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: ChewieController(
        videoPlayerController: _videoPlayerController,
        // Add custom UI configurations
      ),
    );
  }
}
```

### Add New Features

Follow clean architecture:

```
features/new_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

## Performance Optimization

### Caching Strategy
- Memory cache for recent requests (faster)
- Disk cache for persistence
- Automatic TTL-based expiration

### Image Optimization
- Use `CachedNetworkImage` or similar for images
- Compress images on the server
- Use appropriate image formats (WebP for web)

### Memory Management
- Use `dispose()` in Cubits
- Cancel network requests on page close
- Clear caches periodically

## Security Considerations

1. **Credential Storage**
   - Never store passwords in plain text
   - Use `flutter_secure_storage` for sensitive data
   - Use environment variables for API keys

2. **HTTP Security**
   - Use HTTPS when possible
   - Validate server certificates
   - Implement certificate pinning for sensitive servers

3. **Input Validation**
   - Validate URLs before making requests
   - Sanitize user inputs for search
   - Validate file paths

4. **API Security**
   - Implement rate limiting
   - Use proper error handling
   - Don't expose sensitive error messages to users

## License

This project is licensed under the [Your License] license. See the `LICENSE` file for details.

## Support & Resources

### Official Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language](https://dart.dev/)
- [BLoC Documentation](https://bloclibrary.dev/)

### Community Resources
- [Flutter Community](https://flutter.dev/community)
- [StackOverflow #flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter Awesome](https://github.com/Solido/awesome-flutter)

### Get Help
- Check the [Troubleshooting](#troubleshooting) section
- Review existing [GitHub Issues](./issues)
- Create a new issue with detailed information
- Join the Flutter community forums

---

**Last Updated**: November 2025

**Project Version**: 1.0.0

**Maintained By**: SamFTP Team
