import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Server entity representing a SAM-FTP server configuration
class Server extends Equatable {
  final String name;
  final String url;
  final String? username;
  final String? password;
  final double? lastAccessed;
  final String? preferredPlayer;

  const Server({
    required this.name,
    required this.url,
    this.username,
    this.password,
    this.lastAccessed,
    this.preferredPlayer,
  });

  /// For HTTP Basic Auth
  String? get basicAuthHeader {
    if (username != null && password != null) {
      final credentials = base64Encode(utf8.encode('$username:$password'));
      return 'Basic $credentials';
    }
    return null;
  }

  /// Check if server requires authentication
  bool get requiresAuth => username != null && password != null;

  /// Copy with method for immutability
  Server copyWith({
    String? name,
    String? url,
    String? username,
    String? password,
    double? lastAccessed,
    String? preferredPlayer,
  }) {
    return Server(
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      preferredPlayer: preferredPlayer ?? this.preferredPlayer,
    );
  }

  @override
  List<Object?> get props => [
        name,
        url,
        username,
        password,
        lastAccessed,
        preferredPlayer,
      ];
}
