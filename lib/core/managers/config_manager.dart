import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samftp/features/server/data/models/server_dto.dart';
import 'package:samftp/features/server/domain/entities/server.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration Manager for server management and app preferences
class ConfigManager {
  static const _secureStorage = FlutterSecureStorage();
  late final String _configFilePath;
  bool _initialized = false;

  /// Initialize config manager and setup storage directory
  Future<void> init() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    _configFilePath = '${appDir.path}/config.json';
    _initialized = true;
  }

  // ==================== Server Management ====================

  /// Load all servers from storage
  Future<List<Server>> loadServers() async {
    final file = File(_configFilePath);
    if (!await file.exists()) {
      return [];
    }

    try {
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      final serversJson = json['servers'] as List? ?? [];

      final servers = <Server>[];
      for (var serverJson in serversJson) {
        final serverDto = ServerDto.fromJson(serverJson);
        // Load password from secure storage
        if (serverDto.username != null) {
          final password = await _secureStorage.read(
            key: 'server_${serverDto.name}_password',
          );
          servers.add(serverDto.toEntity().copyWith(password: password));
        } else {
          servers.add(serverDto.toEntity());
        }
      }

      return servers;
    } catch (e) {
      debugPrint('Error loading servers: $e');
      return [];
    }
  }

  /// Save all servers to storage
  Future<bool> saveServers(List<Server> servers) async {
    try {
      // Save passwords to secure storage
      for (var server in servers) {
        if (server.password != null) {
          await _secureStorage.write(
            key: 'server_${server.name}_password',
            value: server.password,
          );
        }
      }

      // Save server config (without passwords)
      final serversJson = servers.map((s) {
        return ServerDto.fromEntity(
          Server(
            name: s.name,
            url: s.url,
            username: s.username,
            // Don't include password in JSON
            lastAccessed: s.lastAccessed,
            preferredPlayer: s.preferredPlayer,
          ),
        ).toJson();
      }).toList();

      final config = {
        'servers': serversJson,
      };

      final file = File(_configFilePath);
      await file.writeAsString(jsonEncode(config));
      return true;
    } catch (e) {
      debugPrint('Error saving servers: $e');
      return false;
    }
  }

  /// Add a new server
  Future<bool> addServer(Server server) async {
    final servers = await loadServers();

    // Check if server name already exists
    if (servers.any((s) => s.name == server.name)) {
      return false;
    }

    servers.add(server);
    return await saveServers(servers);
  }

  /// Remove a server by name
  Future<bool> removeServer(String serverName) async {
    final servers = await loadServers();
    servers.removeWhere((s) => s.name == serverName);

    // Remove password from secure storage
    await _secureStorage.delete(key: 'server_${serverName}_password');

    return await saveServers(servers);
  }

  /// Update an existing server
  Future<bool> updateServer(Server server) async {
    final servers = await loadServers();
    final index = servers.indexWhere((s) => s.name == server.name);

    if (index == -1) return false;

    servers[index] = server;
    return await saveServers(servers);
  }

  /// Test server connection
  Future<(bool success, String? error)> testServerConnection(Server server) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        server.url,
        options: Options(
          headers: server.basicAuthHeader != null
              ? {'Authorization': server.basicAuthHeader}
              : null,
          validateStatus: (status) => status != null && status < 500,
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        return (false, 'Authentication required - invalid or missing credentials');
      } else if (response.statusCode == 403) {
        return (false, 'Access forbidden - check permissions');
      } else if (response.statusCode == 404) {
        return (false, 'Server not found - check URL');
      } else if (response.statusCode! >= 400) {
        return (false, 'Server error (HTTP ${response.statusCode})');
      }

      return (true, null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return (false, 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        return (false, 'Connection failed - check network and server address');
      }
      return (false, 'Request error: ${e.message}');
    } catch (e) {
      return (false, 'Unexpected error: $e');
    }
  }

  // ==================== Preferences Management ====================

  /// Get default player preference
  Future<String?> getDefaultPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('default_player');
  }

  /// Set default player preference
  Future<bool> setDefaultPlayer(String player) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('default_player', player);
  }

  /// Get default download directory
  Future<String?> getDefaultDownloadDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('default_download_dir');
  }

  /// Set default download directory
  Future<bool> setDefaultDownloadDirectory(String directory) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('default_download_dir', directory);
  }

  /// Check if this is the first run of the app
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRun = prefs.getBool('has_run') ?? false;

    if (!hasRun) {
      await prefs.setBool('has_run', true);
      return true;
    }

    return false;
  }

  /// Get last selected server name
  Future<String?> getLastSelectedServer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_selected_server');
  }

  /// Set last selected server name
  Future<bool> setLastSelectedServer(String serverName) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('last_selected_server', serverName);
  }

  /// Get cache TTL setting (in minutes)
  Future<int> getCacheTTL() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cache_ttl') ?? 5; // Default 5 minutes
  }

  /// Set cache TTL setting (in minutes)
  Future<bool> setCacheTTL(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt('cache_ttl', minutes);
  }
}
