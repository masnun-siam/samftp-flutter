import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samftp/features/bookmarks/data/models/bookmark_dto.dart';
import 'package:samftp/features/bookmarks/domain/entities/bookmark.dart';

/// Bookmark Manager for CRUD operations on bookmarks
class BookmarkManager {
  late final String _bookmarksFilePath;
  List<Bookmark>? _bookmarksCache;
  bool _initialized = false;

  /// Initialize bookmark manager and setup storage directory
  Future<void> init() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    final configDir = Directory('${appDir.path}/samftp_config');
    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }
    _bookmarksFilePath = '${configDir.path}/bookmarks.json';
    _initialized = true;
  }

  /// Load bookmarks from storage
  Future<List<Bookmark>> _loadBookmarks() async {
    if (_bookmarksCache != null) {
      return _bookmarksCache!;
    }

    final file = File(_bookmarksFilePath);
    if (!await file.exists()) {
      _bookmarksCache = [];
      return _bookmarksCache!;
    }

    try {
      final contents = await file.readAsString();
      final jsonList = json.decode(contents) as List;
      _bookmarksCache = jsonList
          .map((item) => BookmarkDto.fromJson(item as Map<String, dynamic>).toEntity())
          .toList();
      return _bookmarksCache!;
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      _bookmarksCache = [];
      return _bookmarksCache!;
    }
  }

  /// Save bookmarks to storage
  Future<void> _saveBookmarks(List<Bookmark> bookmarks) async {
    final file = File(_bookmarksFilePath);
    try {
      final jsonList = bookmarks
          .map((b) => BookmarkDto.fromEntity(b).toJson())
          .toList();
      await file.writeAsString(json.encode(jsonList));
      _bookmarksCache = bookmarks;
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }

  /// Add a new bookmark
  Future<bool> addBookmark({
    required String name,
    required String server,
    required String url,
  }) async {
    final bookmarks = await _loadBookmarks();

    // Check if name already exists
    if (bookmarks.any((b) => b.name.toLowerCase() == name.toLowerCase())) {
      return false;
    }

    final bookmark = Bookmark(
      name: name,
      server: server,
      url: url,
      timestamp: DateTime.now(),
    );

    bookmarks.add(bookmark);
    await _saveBookmarks(bookmarks);
    return true;
  }

  /// Remove a bookmark by name
  Future<bool> removeBookmark(String name) async {
    final bookmarks = await _loadBookmarks();
    final originalLength = bookmarks.length;

    bookmarks.removeWhere(
      (b) => b.name.toLowerCase() == name.toLowerCase(),
    );

    if (bookmarks.length < originalLength) {
      await _saveBookmarks(bookmarks);
      return true;
    }

    return false;
  }

  /// Get a specific bookmark by name
  Future<Bookmark?> getBookmark(String name) async {
    final bookmarks = await _loadBookmarks();
    try {
      return bookmarks.firstWhere(
        (b) => b.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// List all bookmarks sorted by timestamp (newest first)
  Future<List<Bookmark>> listBookmarks() async {
    final bookmarks = await _loadBookmarks();
    bookmarks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return bookmarks;
  }

  /// Check if a URL is bookmarked and return its name
  Future<String?> isBookmarked(String url) async {
    final bookmarks = await _loadBookmarks();
    try {
      final bookmark = bookmarks.firstWhere((b) => b.url == url);
      return bookmark.name;
    } catch (e) {
      return null;
    }
  }

  /// Update an existing bookmark
  Future<bool> updateBookmark({
    required String name,
    String? newName,
    String? newUrl,
  }) async {
    final bookmarks = await _loadBookmarks();

    try {
      final index = bookmarks.indexWhere(
        (b) => b.name.toLowerCase() == name.toLowerCase(),
      );

      if (index == -1) return false;

      // Check if new name already exists
      if (newName != null &&
          bookmarks.any((b) =>
              b.name.toLowerCase() == newName.toLowerCase() &&
              b.name != bookmarks[index].name)) {
        return false;
      }

      final updatedBookmark = bookmarks[index].copyWith(
        name: newName ?? bookmarks[index].name,
        url: newUrl ?? bookmarks[index].url,
        timestamp: DateTime.now(),
      );

      bookmarks[index] = updatedBookmark;
      await _saveBookmarks(bookmarks);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get bookmarks for a specific server
  Future<List<Bookmark>> getBookmarksByServer(String server) async {
    final bookmarks = await _loadBookmarks();
    return bookmarks.where((b) => b.server == server).toList();
  }

  /// Clear all bookmarks
  Future<int> clearAllBookmarks() async {
    final bookmarks = await _loadBookmarks();
    final count = bookmarks.length;

    if (count > 0) {
      await _saveBookmarks([]);
    }

    return count;
  }

  /// Export bookmarks to a file
  Future<bool> exportBookmarks(String filePath) async {
    final bookmarks = await _loadBookmarks();

    try {
      final jsonList = bookmarks
          .map((b) => BookmarkDto.fromEntity(b).toJson())
          .toList();
      final file = File(filePath);
      await file.writeAsString(json.encode(jsonList));
      return true;
    } catch (e) {
      debugPrint('Error exporting bookmarks: $e');
      return false;
    }
  }

  /// Import bookmarks from a file
  Future<int> importBookmarks(String filePath, {bool merge = true}) async {
    try {
      final file = File(filePath);
      final contents = await file.readAsString();
      final jsonList = json.decode(contents) as List;

      final imported = jsonList
          .map((item) => BookmarkDto.fromJson(item as Map<String, dynamic>).toEntity())
          .toList();

      if (merge) {
        final existing = await _loadBookmarks();
        final existingNames = existing.map((b) => b.name.toLowerCase()).toSet();

        final newBookmarks = imported
            .where((b) => !existingNames.contains(b.name.toLowerCase()))
            .toList();

        final allBookmarks = [...existing, ...newBookmarks];
        await _saveBookmarks(allBookmarks);
        return newBookmarks.length;
      } else {
        await _saveBookmarks(imported);
        return imported.length;
      }
    } catch (e) {
      debugPrint('Error importing bookmarks: $e');
      return 0;
    }
  }
}
