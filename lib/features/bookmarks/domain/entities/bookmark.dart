import 'package:equatable/equatable.dart';

/// Bookmark entity representing a saved directory location
class Bookmark extends Equatable {
  final String name;
  final String server;
  final String url;
  final DateTime timestamp;

  const Bookmark({
    required this.name,
    required this.server,
    required this.url,
    required this.timestamp,
  });

  /// Copy with method for immutability
  Bookmark copyWith({
    String? name,
    String? server,
    String? url,
    DateTime? timestamp,
  }) {
    return Bookmark(
      name: name ?? this.name,
      server: server ?? this.server,
      url: url ?? this.url,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [name, server, url, timestamp];
}
