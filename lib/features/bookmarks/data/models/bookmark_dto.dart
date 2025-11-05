import 'package:samftp/features/bookmarks/domain/entities/bookmark.dart';

/// Bookmark Data Transfer Object for serialization
class BookmarkDto {
  final String name;
  final String server;
  final String url;
  final DateTime timestamp;

  const BookmarkDto({
    required this.name,
    required this.server,
    required this.url,
    required this.timestamp,
  });

  /// Factory for JSON deserialization
  factory BookmarkDto.fromJson(Map<String, dynamic> json) {
    return BookmarkDto(
      name: json['name'] as String,
      server: json['server'] as String,
      url: json['url'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as num) * 1000).toInt(),
      ),
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'server': server,
      'url': url,
      'timestamp': timestamp.millisecondsSinceEpoch / 1000,
    };
  }

  /// Convert DTO to domain entity
  Bookmark toEntity() {
    return Bookmark(
      name: name,
      server: server,
      url: url,
      timestamp: timestamp,
    );
  }

  /// Create DTO from domain entity
  factory BookmarkDto.fromEntity(Bookmark bookmark) {
    return BookmarkDto(
      name: bookmark.name,
      server: bookmark.server,
      url: bookmark.url,
      timestamp: bookmark.timestamp,
    );
  }
}
