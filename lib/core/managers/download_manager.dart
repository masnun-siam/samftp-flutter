import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';

/// Download Manager with progress tracking and cancellation support
class DownloadManager {
  final Dio _dio;
  final String? downloadDirectory;
  final Map<String, CancelToken> _activeTasks = {};

  DownloadManager({
    this.downloadDirectory,
  }) : _dio = Dio();

  /// Get the default download directory
  Future<String> _getDownloadDirectory() async {
    if (downloadDirectory != null) {
      return downloadDirectory!;
    }

    // Try to get Downloads directory
    try {
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        return directory.path;
      }
    } catch (e) {
      debugPrint('Error getting downloads directory: $e');
    }

    // Fallback to app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/Downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  /// Download a single file with progress tracking
  Future<bool> downloadFile({
    required ClickableModel file,
    required Function(double progress) onProgress,
    String? basicAuthHeader,
    CancelToken? cancelToken,
  }) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final filePath = '$downloadDir/${file.name}';

      // Store cancel token for this download
      final token = cancelToken ?? CancelToken();
      _activeTasks[file.url] = token;

      await _dio.download(
        file.url,
        filePath,
        options: Options(
          headers: basicAuthHeader != null
              ? {'Authorization': basicAuthHeader}
              : null,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
          }
        },
        cancelToken: token,
      );

      // Remove from active tasks on completion
      _activeTasks.remove(file.url);
      return true;
    } on DioException catch (e) {
      _activeTasks.remove(file.url);
      if (e.type == DioExceptionType.cancel) {
        debugPrint('Download cancelled: ${file.name}');
      } else {
        debugPrint('Download error: $e');
      }
      return false;
    } catch (e) {
      _activeTasks.remove(file.url);
      debugPrint('Unexpected error during download: $e');
      return false;
    }
  }

  /// Download multiple files sequentially with progress tracking
  Future<List<bool>> downloadFiles({
    required List<ClickableModel> files,
    required Function(int index, double progress) onProgress,
    String? basicAuthHeader,
  }) async {
    final results = <bool>[];

    for (var i = 0; i < files.length; i++) {
      final result = await downloadFile(
        file: files[i],
        onProgress: (progress) => onProgress(i, progress),
        basicAuthHeader: basicAuthHeader,
      );
      results.add(result);
    }

    return results;
  }

  /// Cancel a specific download
  void cancelDownload(String fileUrl) {
    final cancelToken = _activeTasks[fileUrl];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download cancelled by user');
      _activeTasks.remove(fileUrl);
    }
  }

  /// Cancel all active downloads
  void cancelAllDownloads() {
    for (var token in _activeTasks.values) {
      if (!token.isCancelled) {
        token.cancel('All downloads cancelled by user');
      }
    }
    _activeTasks.clear();
  }

  /// Get list of active download URLs
  List<String> getActiveDownloads() {
    return _activeTasks.keys.toList();
  }

  /// Check if a file is currently downloading
  bool isDownloading(String fileUrl) {
    return _activeTasks.containsKey(fileUrl);
  }
}
