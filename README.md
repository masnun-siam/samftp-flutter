# SamFTP

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0.1-green.svg?style=for-the-badge)

**A modern, cross-platform FTP media browser and streaming client built with Flutter**

[Features](#features) • [Installation](#installation) • [Architecture](#architecture) • [Building](#building) • [Contributing](#contributing)

</div>

---

## Overview

SamFTP is a feature-rich FTP client designed specifically for browsing and streaming media content from FTP servers. Built with Flutter, it offers a beautiful, responsive interface with both light and dark themes, making it perfect for accessing your media library from anywhere.

Whether you want to browse movies, series, anime, or other media content on your FTP server, SamFTP provides a seamless experience with powerful features like bookmarks, playlists, offline downloads, and multiple video player support.

## Features

### Core Functionality
- **FTP Server Connection** - Connect to multiple FTP servers with secure credential storage
- **Media Browsing** - Navigate through your media library with an intuitive file explorer
- **Video Streaming** - Stream videos directly from FTP servers without downloading
- **Audio Playback** - Built-in audio player for music files
- **Image Viewing** - High-quality image viewer with zoom and pan capabilities
- **Search** - Fuzzy search across your entire media library
- **Download Manager** - Download media files for offline viewing

### Content Organization
- **Bookmarks** - Save your favorite folders and files for quick access
- **Playlists** - Create and manage M3U playlists from your media collection
- **Categories** - Pre-organized categories for different types of content:
  - English Movies
  - Series & TV Shows
  - Korean Dramas (K-Dramas)
  - Anime
  - Animation Movies
  - Hindi Movies
  - South Movies
  - Bangla Movies
  - Foreign Movies

### User Experience
- **Material Design 3** - Modern, beautiful UI following latest Material Design guidelines
- **Dark Mode** - Full dark theme support with automatic switching
- **Responsive Design** - Optimized for mobile, tablet, and desktop devices
- **Cross-Platform** - Works on Android, iOS, Windows, macOS, and Linux
- **Offline Support** - Cache management and offline file access
- **Network Resilience** - Automatic retry logic and connection monitoring

### Technical Features
- **Clean Architecture** - Separation of concerns with domain, data, and presentation layers
- **BLoC State Management** - Predictable state management using flutter_bloc
- **Dependency Injection** - Injectable and GetIt for clean dependency management
- **Type Safety** - Functional programming with fpdart for error handling
- **Secure Storage** - Encrypted credential storage using flutter_secure_storage
- **Auto Routing** - Type-safe navigation with auto_route

## Screenshots

> Add screenshots of your app here to showcase the UI

## Tech Stack

### Framework & Language
- **Flutter** (SDK 3.0.3+) - UI framework
- **Dart** - Programming language

### State Management & Architecture
- **flutter_bloc** (^9.1.1) - BLoC pattern implementation
- **fpdart** (^1.1.0) - Functional programming and Either types
- **equatable** (^2.0.5) - Value equality
- **get_it** (^8.0.3) - Service locator for dependency injection
- **injectable** (^2.1.2) - Code generation for dependency injection

### Networking
- **dio** (^5.7.0) - HTTP client for FTP communication
- **internet_connection_checker** (^3.0.1) - Network connectivity monitoring
- **dart_ping** (^9.0.0) - Server availability checking

### Media Players
- **media_kit** - Advanced video playback
- **video_player** (^2.9.5) - Video playback
- **chewie** (^1.11.3) - Video player UI
- **external_video_player_launcher** - External player integration

### Storage & Caching
- **shared_preferences** (^2.1.2) - Key-value storage
- **flutter_secure_storage** (^9.0.0) - Encrypted credential storage
- **path_provider** (^2.1.1) - File system paths

### UI Components
- **easy_image_viewer** (^1.2.1) - Image viewing
- **responsive_framework** (^1.5.0) - Responsive layouts
- **auto_size_text** (^3.0.0) - Dynamic text sizing
- **share_plus** (^11.0.0) - Native sharing

### Navigation
- **auto_route** (^10.2.0) - Type-safe routing

### Utilities
- **html** (^0.15.4) - HTML parsing for FTP directory listings
- **string_similarity** (^2.0.0) - Fuzzy search
- **intl** (^0.18.1) - Internationalization and date formatting
- **logger** (^2.0.2) - Logging framework
- **crypto** (^3.0.3) - Cryptographic operations

## Architecture

SamFTP follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                      # Core functionality shared across features
│   ├── error/                 # Error handling and exceptions
│   ├── helper/                # Utility helpers
│   ├── managers/              # App-wide managers
│   │   ├── bookmark_manager.dart
│   │   ├── cache_manager.dart
│   │   ├── config_manager.dart
│   │   └── download_manager.dart
│   ├── network/               # Network utilities
│   ├── routes/                # App routing configuration
│   └── usecase/               # Base use case classes
├── di/                        # Dependency injection configuration
├── features/                  # Feature modules
│   ├── bookmarks/
│   │   ├── data/             # Data layer (DTOs, datasources)
│   │   ├── domain/           # Domain layer (entities, repositories)
│   │   └── presentation/     # UI layer (pages, widgets, cubits)
│   ├── folders/              # File browsing
│   ├── home/                 # Home screen
│   ├── player/               # Media player
│   ├── playlists/            # Playlist management
│   └── server/               # Server management
└── main.dart
```

### Key Patterns

- **Repository Pattern** - Abstracts data sources
- **BLoC Pattern** - Manages UI state
- **Dependency Injection** - Loose coupling between components
- **Either Type** - Functional error handling with fpdart
- **Use Cases** - Business logic encapsulation

## Installation

### Prerequisites

- Flutter SDK (3.0.3 or higher)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- Visual Studio (for Windows development)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/masnun-siam/samftp-flutter.git
   cd samftp-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

The app requires FTP server credentials to function. On first launch:

1. Open the app
2. Navigate to server settings
3. Add your FTP server details:
   - Server name
   - Server URL
   - Username
   - Password (stored securely)

## Building

### Android APK

```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Windows

```bash
flutter build windows --release
```

### macOS

```bash
flutter build macos --release
```

### Linux

```bash
flutter build linux --release
```

### Web

```bash
flutter build web --release
```

## Development

### Code Generation

This project uses code generation for:
- **Routing** (auto_route)
- **Dependency Injection** (injectable)
- **Serialization** (freezed)

To regenerate code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

To watch for changes:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running Tests

```bash
flutter test
```

### Code Style

This project follows the official Dart style guide and uses `flutter_lints`.

```bash
flutter analyze
```

## CI/CD

The project includes GitHub Actions workflow for automated releases:
- Automatic APK builds on version tags
- GitHub Releases creation with APK artifacts

See `.github/workflows/release.yml` for details.

## Project Highlights

### Modern Dependencies
SamFTP uses actively maintained packages, replacing abandoned alternatives:
- ✅ **fpdart** instead of dartz (abandoned)
- ✅ **string_similarity** instead of fuzzywuzzy (outdated)
- ✅ **responsive_framework** instead of responsive_builder (outdated)

### Security
- Encrypted credential storage using flutter_secure_storage
- Secure HTTP connections
- No hardcoded credentials

### Performance
- Efficient caching mechanism
- Lazy loading of directory contents
- Network retry logic with exponential backoff
- Optimized image loading

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clean Architecture principles
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Follow Dart style guidelines

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Uses [Media Kit](https://github.com/media-kit/media-kit) for advanced video playback
- Inspired by the need for a modern FTP media browser

## Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check existing issues for solutions

## Roadmap

- [ ] Subtitle support for videos
- [ ] Chromecast support
- [ ] Multiple server sync
- [ ] Advanced search filters
- [ ] Thumbnail generation
- [ ] Upload functionality
- [ ] File management (rename, delete, move)

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ back to top](#samftp)

</div>
