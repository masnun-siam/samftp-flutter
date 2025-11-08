import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:samftp/features/playlists/domain/entities/playlist_item.dart';

class M3uGenerator {
  /// Generates an M3U playlist file from a list of playlist items
  /// Returns the file path of the generated M3U file
  Future<String> generateM3uFile(
    String playlistName,
    List<PlaylistItem> items,
  ) async {
    final buffer = StringBuffer();

    // M3U header
    buffer.writeln('#EXTM3U');
    buffer.writeln();

    // Add each item
    for (final item in items) {
      // EXTINF line with duration and title
      final duration = item.duration?.inSeconds ?? -1;
      buffer.writeln('#EXTINF:$duration,${item.title}');

      // URL line
      buffer.writeln(item.url);
      buffer.writeln();
    }

    // Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final fileName = _sanitizeFileName(playlistName);
    final file = File('${tempDir.path}/$fileName.m3u');

    await file.writeAsString(buffer.toString());

    return file.path;
  }

  /// Generates M3U content as a string (for sharing via network)
  String generateM3uContent(List<PlaylistItem> items) {
    final buffer = StringBuffer();

    // M3U header
    buffer.writeln('#EXTM3U');
    buffer.writeln();

    // Add each item
    for (final item in items) {
      // EXTINF line with duration and title
      final duration = item.duration?.inSeconds ?? -1;
      buffer.writeln('#EXTINF:$duration,${item.title}');

      // URL line
      buffer.writeln(item.url);
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Sanitizes a filename by removing invalid characters
  String _sanitizeFileName(String name) {
    // Remove or replace invalid filename characters
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Parses an M3U file and returns a list of playlist items
  Future<List<PlaylistItem>> parseM3uFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('M3U file not found: $filePath');
    }

    final content = await file.readAsString();
    return parseM3uContent(content);
  }

  /// Parses M3U content string and returns a list of playlist items
  List<PlaylistItem> parseM3uContent(String content) {
    final items = <PlaylistItem>[];
    final lines = content.split('\n');

    String? currentTitle;
    Duration? currentDuration;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF:')) {
        // Parse EXTINF line: #EXTINF:duration,title
        final parts = line.substring(8).split(',');
        if (parts.isNotEmpty) {
          final durationStr = parts[0].trim();
          final duration = int.tryParse(durationStr);
          if (duration != null && duration > 0) {
            currentDuration = Duration(seconds: duration);
          }

          if (parts.length > 1) {
            currentTitle = parts.sublist(1).join(',').trim();
          }
        }
      } else if (line.startsWith('#')) {
        // Skip other comment lines
        continue;
      } else {
        // This is a URL line
        final url = line;
        final title = currentTitle ?? _extractTitleFromUrl(url);
        final mimeType = _guessMimeType(url);

        items.add(PlaylistItem(
          title: title,
          url: url,
          mimeType: mimeType,
          duration: currentDuration,
        ));

        // Reset for next item
        currentTitle = null;
        currentDuration = null;
      }
    }

    return items;
  }

  /// Extracts a title from a URL (last path segment)
  String _extractTitleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return Uri.decodeComponent(segments.last);
      }
    } catch (e) {
      // Fallback to simple extraction
    }

    final lastSlash = url.lastIndexOf('/');
    if (lastSlash >= 0 && lastSlash < url.length - 1) {
      return Uri.decodeComponent(url.substring(lastSlash + 1));
    }

    return url;
  }

  /// Guesses MIME type from URL extension
  String _guessMimeType(String url) {
    final lowerUrl = url.toLowerCase();

    // Video types
    if (lowerUrl.endsWith('.mp4')) return 'video/mp4';
    if (lowerUrl.endsWith('.mkv')) return 'video/x-matroska';
    if (lowerUrl.endsWith('.avi')) return 'video/x-msvideo';
    if (lowerUrl.endsWith('.mov')) return 'video/quicktime';
    if (lowerUrl.endsWith('.webm')) return 'video/webm';

    // Audio types
    if (lowerUrl.endsWith('.mp3')) return 'audio/mpeg';
    if (lowerUrl.endsWith('.wav')) return 'audio/wav';
    if (lowerUrl.endsWith('.flac')) return 'audio/flac';
    if (lowerUrl.endsWith('.m4a')) return 'audio/mp4';
    if (lowerUrl.endsWith('.aac')) return 'audio/aac';
    if (lowerUrl.endsWith('.ogg')) return 'audio/ogg';

    return 'application/octet-stream';
  }
}
