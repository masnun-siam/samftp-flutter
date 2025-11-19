import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Model for video progress information
class VideoProgress {
  final String videoUrl;
  final Duration position;
  final Duration duration;
  final bool isCompleted;
  final DateTime lastWatched;

  VideoProgress({
    required this.videoUrl,
    required this.position,
    required this.duration,
    required this.isCompleted,
    required this.lastWatched,
  });

  /// Calculate progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  /// Check if video should be marked as completed (85% threshold)
  bool get shouldAutoComplete => progressPercentage >= 0.85;

  Map<String, dynamic> toJson() => {
        'videoUrl': videoUrl,
        'position': position.inMilliseconds,
        'duration': duration.inMilliseconds,
        'isCompleted': isCompleted,
        'lastWatched': lastWatched.millisecondsSinceEpoch,
      };

  factory VideoProgress.fromJson(Map<String, dynamic> json) => VideoProgress(
        videoUrl: json['videoUrl'] as String,
        position: Duration(milliseconds: json['position'] as int),
        duration: Duration(milliseconds: json['duration'] as int),
        isCompleted: json['isCompleted'] as bool,
        lastWatched: DateTime.fromMillisecondsSinceEpoch(json['lastWatched'] as int),
      );

  VideoProgress copyWith({
    String? videoUrl,
    Duration? position,
    Duration? duration,
    bool? isCompleted,
    DateTime? lastWatched,
  }) {
    return VideoProgress(
      videoUrl: videoUrl ?? this.videoUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatched: lastWatched ?? this.lastWatched,
    );
  }
}

/// Manager for tracking video playback progress and completion status
class VideoProgressManager {
  static const String _keyPrefix = 'video_progress_';
  static const String _allVideosKey = 'all_video_urls';

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Initialize the manager
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Ensure the manager is initialized
  void _ensureInitialized() {
    if (!_initialized || _prefs == null) {
      throw StateError('VideoProgressManager not initialized. Call init() first.');
    }
  }

  /// Save video progress
  Future<bool> saveProgress({
    required String videoUrl,
    required Duration position,
    required Duration duration,
    bool? forceCompleted,
  }) async {
    _ensureInitialized();

    // Get existing progress or create new
    final existingProgress = await getProgress(videoUrl);

    // Determine if video should be marked as completed
    final progressPercentage = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    final shouldComplete = forceCompleted ?? progressPercentage >= 0.85;

    // Preserve completed status if already marked as completed
    // Only set to completed if it should be completed or was already completed
    final isCompleted = (existingProgress?.isCompleted ?? false) || shouldComplete;

    final progress = VideoProgress(
      videoUrl: videoUrl,
      position: position,
      duration: duration,
      isCompleted: isCompleted,
      lastWatched: DateTime.now(),
    );

    // Save progress
    final key = _keyPrefix + _urlToKey(videoUrl);
    final saved = await _prefs!.setString(key, json.encode(progress.toJson()));

    if (saved) {
      // Add to list of all videos
      await _addToAllVideos(videoUrl);
    }

    return saved;
  }

  /// Get video progress
  Future<VideoProgress?> getProgress(String videoUrl) async {
    _ensureInitialized();

    final key = _keyPrefix + _urlToKey(videoUrl);
    final data = _prefs!.getString(key);

    if (data == null) return null;

    try {
      return VideoProgress.fromJson(json.decode(data) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error loading video progress: $e');
      return null;
    }
  }

  /// Mark video as completed manually
  Future<bool> markAsCompleted(String videoUrl, Duration duration) async {
    _ensureInitialized();

    final existingProgress = await getProgress(videoUrl);

    final progress = VideoProgress(
      videoUrl: videoUrl,
      position: existingProgress?.position ?? duration,
      duration: duration,
      isCompleted: true,
      lastWatched: DateTime.now(),
    );

    final key = _keyPrefix + _urlToKey(videoUrl);
    final saved = await _prefs!.setString(key, json.encode(progress.toJson()));

    if (saved) {
      await _addToAllVideos(videoUrl);
    }

    return saved;
  }

  /// Mark video as incomplete
  Future<bool> markAsIncomplete(String videoUrl) async {
    _ensureInitialized();

    final existingProgress = await getProgress(videoUrl);
    if (existingProgress == null) return false;

    final progress = existingProgress.copyWith(
      isCompleted: false,
      lastWatched: DateTime.now(),
    );

    final key = _keyPrefix + _urlToKey(videoUrl);
    return await _prefs!.setString(key, json.encode(progress.toJson()));
  }

  /// Get progress for multiple videos
  Future<Map<String, VideoProgress>> getProgressForVideos(List<String> videoUrls) async {
    _ensureInitialized();

    final Map<String, VideoProgress> progressMap = {};

    for (final url in videoUrls) {
      final progress = await getProgress(url);
      if (progress != null) {
        progressMap[url] = progress;
      }
    }

    return progressMap;
  }

  /// Get progress statistics for a folder
  Future<FolderProgress> getFolderProgress(List<String> videoUrls) async {
    _ensureInitialized();

    if (videoUrls.isEmpty) {
      return FolderProgress(
        totalVideos: 0,
        completedVideos: 0,
        inProgressVideos: 0,
        unwatchedVideos: 0,
        overallProgress: 0.0,
      );
    }

    int completed = 0;
    int inProgress = 0;
    int unwatched = 0;
    double totalProgress = 0.0;

    for (final url in videoUrls) {
      final progress = await getProgress(url);

      if (progress == null) {
        unwatched++;
      } else if (progress.isCompleted) {
        completed++;
        totalProgress += 1.0;
      } else {
        inProgress++;
        totalProgress += progress.progressPercentage;
      }
    }

    return FolderProgress(
      totalVideos: videoUrls.length,
      completedVideos: completed,
      inProgressVideos: inProgress,
      unwatchedVideos: unwatched,
      overallProgress: totalProgress / videoUrls.length,
    );
  }

  /// Delete progress for a video
  Future<bool> deleteProgress(String videoUrl) async {
    _ensureInitialized();

    final key = _keyPrefix + _urlToKey(videoUrl);
    final removed = await _prefs!.remove(key);

    if (removed) {
      await _removeFromAllVideos(videoUrl);
    }

    return removed;
  }

  /// Clear all video progress
  Future<void> clearAllProgress() async {
    _ensureInitialized();

    final allVideos = await _getAllVideos();
    for (final url in allVideos) {
      final key = _keyPrefix + _urlToKey(url);
      await _prefs!.remove(key);
    }

    await _prefs!.remove(_allVideosKey);
  }

  /// Get all tracked videos
  Future<List<String>> getAllTrackedVideos() async {
    _ensureInitialized();
    return await _getAllVideos();
  }

  /// Convert URL to a valid SharedPreferences key
  String _urlToKey(String url) {
    return url.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  /// Add video URL to the list of all videos
  Future<void> _addToAllVideos(String videoUrl) async {
    final allVideos = await _getAllVideos();
    if (!allVideos.contains(videoUrl)) {
      allVideos.add(videoUrl);
      await _prefs!.setStringList(_allVideosKey, allVideos);
    }
  }

  /// Remove video URL from the list of all videos
  Future<void> _removeFromAllVideos(String videoUrl) async {
    final allVideos = await _getAllVideos();
    allVideos.remove(videoUrl);
    await _prefs!.setStringList(_allVideosKey, allVideos);
  }

  /// Get all video URLs
  Future<List<String>> _getAllVideos() async {
    return _prefs!.getStringList(_allVideosKey) ?? [];
  }

  /// Export all progress data to a JSON file
  /// Returns the file path on success, null on failure
  Future<String?> exportProgress() async {
    _ensureInitialized();

    try {
      // Get all tracked videos
      final allVideos = await _getAllVideos();

      if (allVideos.isEmpty) {
        return null;
      }

      // Collect all progress data
      final List<Map<String, dynamic>> progressList = [];

      for (final url in allVideos) {
        final progress = await getProgress(url);
        if (progress != null) {
          progressList.add(progress.toJson());
        }
      }

      // Create export data structure
      final exportData = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'totalVideos': progressList.length,
        'progress': progressList,
      };

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/video_progress_export_$timestamp.json';
      final file = File(filePath);

      await file.writeAsString(json.encode(exportData));

      return filePath;
    } catch (e) {
      debugPrint('Error exporting progress: $e');
      return null;
    }
  }

  /// Import progress data from a JSON file
  /// Returns the number of items imported, or -1 on failure
  Future<ImportResult> importProgress(String filePath, {bool mergeMode = true}) async {
    _ensureInitialized();

    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return ImportResult(
          success: false,
          itemsImported: 0,
          itemsSkipped: 0,
          itemsUpdated: 0,
          error: 'File not found',
        );
      }

      // Read and parse file
      final contents = await file.readAsString();
      final importData = json.decode(contents) as Map<String, dynamic>;

      // Validate version
      if (importData['version'] != 1) {
        return ImportResult(
          success: false,
          itemsImported: 0,
          itemsSkipped: 0,
          itemsUpdated: 0,
          error: 'Unsupported file version',
        );
      }

      final progressList = importData['progress'] as List;
      int imported = 0;
      int skipped = 0;
      int updated = 0;

      for (final progressJson in progressList) {
        final progress = VideoProgress.fromJson(progressJson as Map<String, dynamic>);

        if (mergeMode) {
          // In merge mode, only import if newer or doesn't exist
          final existing = await getProgress(progress.videoUrl);

          if (existing == null) {
            // New entry
            await saveProgress(
              videoUrl: progress.videoUrl,
              position: progress.position,
              duration: progress.duration,
              forceCompleted: progress.isCompleted,
            );
            imported++;
          } else if (progress.lastWatched.isAfter(existing.lastWatched)) {
            // Update if imported data is newer
            await saveProgress(
              videoUrl: progress.videoUrl,
              position: progress.position,
              duration: progress.duration,
              forceCompleted: progress.isCompleted,
            );
            updated++;
          } else {
            // Skip older data
            skipped++;
          }
        } else {
          // Replace mode - overwrite everything
          await saveProgress(
            videoUrl: progress.videoUrl,
            position: progress.position,
            duration: progress.duration,
            forceCompleted: progress.isCompleted,
          );
          imported++;
        }
      }

      return ImportResult(
        success: true,
        itemsImported: imported,
        itemsSkipped: skipped,
        itemsUpdated: updated,
      );
    } catch (e) {
      debugPrint('Error importing progress: $e');
      return ImportResult(
        success: false,
        itemsImported: 0,
        itemsSkipped: 0,
        itemsUpdated: 0,
        error: e.toString(),
      );
    }
  }

  /// Get export statistics
  Future<Map<String, dynamic>> getExportStats() async {
    _ensureInitialized();

    final allVideos = await _getAllVideos();
    int completed = 0;
    int inProgress = 0;

    for (final url in allVideos) {
      final progress = await getProgress(url);
      if (progress != null) {
        if (progress.isCompleted) {
          completed++;
        } else {
          inProgress++;
        }
      }
    }

    return {
      'totalVideos': allVideos.length,
      'completedVideos': completed,
      'inProgressVideos': inProgress,
    };
  }
}

/// Result of import operation
class ImportResult {
  final bool success;
  final int itemsImported;
  final int itemsSkipped;
  final int itemsUpdated;
  final String? error;

  ImportResult({
    required this.success,
    required this.itemsImported,
    required this.itemsSkipped,
    required this.itemsUpdated,
    this.error,
  });

  int get totalProcessed => itemsImported + itemsSkipped + itemsUpdated;
}

/// Model for folder progress statistics
class FolderProgress {
  final int totalVideos;
  final int completedVideos;
  final int inProgressVideos;
  final int unwatchedVideos;
  final double overallProgress; // 0.0 to 1.0

  FolderProgress({
    required this.totalVideos,
    required this.completedVideos,
    required this.inProgressVideos,
    required this.unwatchedVideos,
    required this.overallProgress,
  });

  /// Get completion percentage as integer (0-100)
  int get completionPercentage => (overallProgress * 100).round();

  bool get hasAnyProgress => completedVideos > 0 || inProgressVideos > 0;
  bool get isFullyCompleted => totalVideos > 0 && completedVideos == totalVideos;
}
