import 'package:samftp/features/server/domain/entities/server.dart';

/// Server Data Transfer Object for serialization
class ServerDto {
  final String name;
  final String url;
  final String? username;
  final String? password;
  final double? lastAccessed;
  final String? preferredPlayer;

  const ServerDto({
    required this.name,
    required this.url,
    this.username,
    this.password,
    this.lastAccessed,
    this.preferredPlayer,
  });

  /// Factory for JSON deserialization
  factory ServerDto.fromJson(Map<String, dynamic> json) {
    return ServerDto(
      name: json['name'] as String,
      url: json['url'] as String,
      username: json['username'] as String?,
      password: json['password'] as String?,
      lastAccessed: json['last_accessed'] as double?,
      preferredPlayer: json['preferred_player'] as String?,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'username': username,
      'password': password,
      'last_accessed': lastAccessed,
      'preferred_player': preferredPlayer,
    };
  }

  /// Convert DTO to domain entity
  Server toEntity() {
    return Server(
      name: name,
      url: url,
      username: username,
      password: password,
      lastAccessed: lastAccessed,
      preferredPlayer: preferredPlayer,
    );
  }

  /// Create DTO from domain entity
  factory ServerDto.fromEntity(Server server) {
    return ServerDto(
      name: server.name,
      url: server.url,
      username: server.username,
      password: server.password,
      lastAccessed: server.lastAccessed,
      preferredPlayer: server.preferredPlayer,
    );
  }
}
