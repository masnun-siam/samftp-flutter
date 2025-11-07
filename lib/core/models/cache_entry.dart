import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';

/// Cache Entry model for directory listings with TTL support
class CacheEntry {
  final String url;
  final DateTime timestamp;
  final List<ClickableModel> items;

  const CacheEntry({
    required this.url,
    required this.timestamp,
    required this.items,
  });

  /// Check if cache entry is expired based on TTL
  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }

  /// Convert to JSON for disk storage
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'items': items.map((item) => {
        'name': item.name,
        'url': item.url,
        'isFolder': item.isFolder,
        'mimeType': item.mimeType,
      }).toList(),
    };
  }

  /// Create from JSON
  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      url: json['url'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      items: (json['items'] as List)
          .map((item) => ClickableModel(
                title: item['name'] as String,
                route: item['url'] as String,
                isFile: !(item['isFolder'] as bool),
                subtitle: item['mimeType'] as String? ?? '',
              ))
          .toList(),
    );
  }
}
