import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samftp/core/models/cache_entry.dart';
import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';

/// Cache Manager with TTL-based caching (memory + disk)
class CacheManager {
  final Duration ttl;
  final Map<String, CacheEntry> _memoryCache = {};
  late final String _cacheFilePath;
  bool _initialized = false;

  CacheManager({
    this.ttl = const Duration(minutes: 5),
  });

  /// Initialize cache manager and setup cache directory
  Future<void> init() async {
    if (_initialized) return;

    final cacheDir = await getApplicationCacheDirectory();
    final samfptDir = Directory('${cacheDir.path}/samftp_cache');
    if (!await samfptDir.exists()) {
      await samfptDir.create(recursive: true);
    }
    _cacheFilePath = '${samfptDir.path}/directory_cache.json';
    _initialized = true;
  }

  /// Convert URL to hash for cache key
  String _urlToHash(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get cached directory listing
  Future<List<ClickableModel>?> getCachedListing(String url) async {
    final urlHash = _urlToHash(url);

    // Check memory cache first
    if (_memoryCache.containsKey(urlHash)) {
      final entry = _memoryCache[urlHash]!;
      if (!entry.isExpired(ttl)) {
        return entry.items;
      } else {
        _memoryCache.remove(urlHash);
      }
    }

    // Check disk cache
    final cacheData = await _loadCacheFromDisk();
    if (cacheData.containsKey(urlHash)) {
      final entryJson = cacheData[urlHash];
      final entry = CacheEntry.fromJson(entryJson);

      if (!entry.isExpired(ttl)) {
        _memoryCache[urlHash] = entry;
        return entry.items;
      } else {
        cacheData.remove(urlHash);
        await _saveCacheToDisk(cacheData);
      }
    }

    return null;
  }

  /// Cache directory listing
  Future<void> cacheListing(String url, List<ClickableModel> items) async {
    final urlHash = _urlToHash(url);
    final entry = CacheEntry(
      url: url,
      timestamp: DateTime.now(),
      items: items,
    );

    // Update memory cache
    _memoryCache[urlHash] = entry;

    // Update disk cache
    final cacheData = await _loadCacheFromDisk();
    cacheData[urlHash] = entry.toJson();
    await _saveCacheToDisk(cacheData);
  }

  /// Invalidate cache for specific URL
  Future<void> invalidateCache(String url) async {
    final urlHash = _urlToHash(url);

    // Remove from memory
    _memoryCache.remove(urlHash);

    // Remove from disk
    final cacheData = await _loadCacheFromDisk();
    cacheData.remove(urlHash);
    await _saveCacheToDisk(cacheData);
  }

  /// Clear all cached entries
  Future<void> clearAllCache() async {
    _memoryCache.clear();

    final file = File(_cacheFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final cacheData = await _loadCacheFromDisk();
    final totalEntries = cacheData.length;

    int expiredEntries = 0;
    for (var entryJson in cacheData.values) {
      final entry = CacheEntry.fromJson(entryJson);
      if (entry.isExpired(ttl)) {
        expiredEntries++;
      }
    }

    final validEntries = totalEntries - expiredEntries;

    final file = File(_cacheFilePath);
    final cacheSize = await file.exists() ? await file.length() : 0;

    return {
      'total_entries': totalEntries,
      'valid_entries': validEntries,
      'expired_entries': expiredEntries,
      'cache_size_bytes': cacheSize,
      'cache_size_kb': cacheSize / 1024,
      'cache_location': _cacheFilePath,
      'ttl_seconds': ttl.inSeconds,
    };
  }

  /// Cleanup expired cache entries
  Future<int> cleanupExpired() async {
    final cacheData = await _loadCacheFromDisk();
    final originalSize = cacheData.length;

    cacheData.removeWhere((key, value) {
      final entry = CacheEntry.fromJson(value);
      return entry.isExpired(ttl);
    });

    final removedCount = originalSize - cacheData.length;
    if (removedCount > 0) {
      await _saveCacheToDisk(cacheData);
    }

    return removedCount;
  }

  /// Load cache data from disk
  Future<Map<String, dynamic>> _loadCacheFromDisk() async {
    final file = File(_cacheFilePath);
    if (!await file.exists()) {
      return {};
    }

    try {
      final contents = await file.readAsString();
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading cache: $e');
      return {};
    }
  }

  /// Save cache data to disk
  Future<void> _saveCacheToDisk(Map<String, dynamic> cacheData) async {
    final file = File(_cacheFilePath);
    try {
      await file.writeAsString(json.encode(cacheData));
    } catch (e) {
      debugPrint('Error saving cache: $e');
    }
  }
}
