import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Singleton AppLogger for centralized logging
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;

  late final Logger _logger;
  late final File _logFile;
  bool _initialized = false;

  AppLogger._internal();

  /// Initialize logger with file output
  Future<void> init() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    _logFile = File('${logDir.path}/app.log');

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: _logFile),
      ]),
    );

    _initialized = true;
  }

  /// Log an error with optional context and stack trace
  void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final message = [
      '=' * 80,
      'Timestamp: $timestamp',
      if (context != null) 'Context: $context',
      'Error Type: ${error.runtimeType}',
      'Error Message: $error',
      if (stackTrace != null) '\nStack Trace:\n$stackTrace',
      '=' * 80,
    ].join('\n');

    _logger.e(message);
  }

  /// Log an info message
  void logInfo(String message, {String? context}) {
    _logger.i(context != null ? '[$context] $message' : message);
  }

  /// Log a warning message
  void logWarning(String message, {String? context}) {
    _logger.w(context != null ? '[$context] $message' : message);
  }

  /// Log a debug message
  void logDebug(String message, {String? context}) {
    _logger.d(context != null ? '[$context] $message' : message);
  }

  /// Get log file path
  Future<String> getLogFilePath() async {
    return _logFile.path;
  }

  /// Get log contents as string
  Future<String> getLogContents() async {
    if (await _logFile.exists()) {
      return await _logFile.readAsString();
    }
    return '';
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    if (await _logFile.exists()) {
      await _logFile.delete();
    }
  }
}

/// Custom file output for logger
class FileOutput extends LogOutput {
  final File file;

  FileOutput({required this.file});

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      file.writeAsStringSync('$line\n', mode: FileMode.append);
    }
  }
}
