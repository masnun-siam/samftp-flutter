import 'dart:ui';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:samftp/di/di.dart';
import 'package:samftp/features/home/presentation/cubit/content_cubit.dart';
import 'package:samftp/features/home/presentation/widgets/list_item.dart';
import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';
import 'package:samftp/features/playlists/domain/entities/playlist_item.dart';
import 'package:samftp/features/playlists/presentation/cubit/playlist_cubit.dart';
import 'package:samftp/features/playlists/data/services/m3u_generator.dart';
import 'package:samftp/features/player/presentation/pages/player_page.dart';
import 'package:samftp/core/managers/bookmark_manager.dart';
import 'package:samftp/core/managers/download_manager.dart';
import 'package:samftp/core/managers/video_progress_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/routes/app_routes.gr.dart';
import '../cubit/content_state.dart';
import 'content_search_deligate.dart';

@RoutePage()
class ContentPage extends StatelessWidget {
  final String url;

  final String title;
  final String base;
  const ContentPage(
      {super.key, required this.title, required this.url, required this.base});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ContentCubit, ContentState>(
      bloc: getIt<ContentCubit>()..load(url),
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: (isDark
                ? const Color(0xFF1F2937)
                : Colors.white).withOpacity(0.7),
            elevation: 0,
            title: Text(
              Uri.decodeFull(url.split('/').last),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            leading: Navigator.canPop(context)
                ? Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05)),
                    ),
                    child: IconButton(
                      style: TextButton.styleFrom(
                        iconColor: isDark ? Colors.white : const Color(0xFF1F2937),
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  )
                : null,
            automaticallyImplyLeading: false,
            actions: [
              if (state is ContentLoaded) ...[
                // Progress management menu
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05)),
                  ),
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.settings_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tooltip: 'Progress Management',
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'export_progress',
                          onTap: () => _exportProgress(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.upload_file_rounded,
                                size: 20,
                                color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937),
                              ),
                              const SizedBox(width: 12),
                              const Text('Export Progress'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'import_progress',
                          onTap: () => _importProgress(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.download_rounded,
                                size: 20,
                                color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937),
                              ),
                              const SizedBox(width: 12),
                              const Text('Import Progress'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'progress_stats',
                          onTap: () => _showProgressStats(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.analytics_rounded,
                                size: 20,
                                color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937),
                              ),
                              const SizedBox(width: 12),
                              const Text('Progress Statistics'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ),
                // Playlist actions menu
                if (_hasMediaFiles(state.models))
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05)),
                    ),
                    child: PopupMenuButton(
                      icon: Icon(
                        Icons.playlist_play_rounded,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tooltip: 'Playlist Actions',
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: 'play_all',
                            onTap: () => _playAllMedia(context, state),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline_rounded,
                                  size: 20,
                                  color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937),
                                ),
                                const SizedBox(width: 12),
                                const Text('Play All'),
                              ],
                            ),
                          ),
                          // Show "Share Playlist" on mobile, "Open with MPV" on desktop
                          if (Platform.isAndroid || Platform.isIOS)
                            PopupMenuItem(
                              value: 'share_playlist',
                              onTap: () => _sharePlaylist(context, state),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.share_rounded,
                                    size: 20,
                                    color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Share Playlist (M3U)'),
                                ],
                              ),
                            )
                          else
                            PopupMenuItem(
                              value: 'open_mpv',
                              onTap: () => _openWithMpv(context, state),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    size: 20,
                                    color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Open Playlist with MPV'),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'download_all',
                            onTap: () => _downloadAllMedia(context, state),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.download_rounded,
                                  size: 20,
                                  color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937),
                                ),
                                const SizedBox(width: 12),
                                const Text('Download All'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'bookmark',
                            onTap: () => _bookmarkFolder(context),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bookmark_add_rounded,
                                  size: 20,
                                  color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937),
                                ),
                                const SizedBox(width: 12),
                                const Text('Bookmark Folder'),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ),
                // Search button
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05)),
                  ),
                  child: IconButton(
                    style: TextButton.styleFrom(
                      iconColor: isDark ? Colors.white : const Color(0xFF1F2937),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () {
                      _search(context, state);
                    },
                    icon: const Icon(Icons.search_rounded, size: 20),
                  ),
                ),
              ],
            ],
          ),
          body: switch (state) {
            ContentInitial() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A),
                            const Color(0xFF1E293B),
                          ]
                        : [
                            const Color(0xFFF5F5F7),
                            const Color(0xFFEDE9FE),
                          ],
                  ),
                ),
              ),
            ContentLoading() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A),
                            const Color(0xFF1E293B),
                          ]
                        : [
                            const Color(0xFFF5F5F7),
                            const Color(0xFFEDE9FE),
                          ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ContentError() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A),
                            const Color(0xFF1E293B),
                          ]
                        : [
                            const Color(0xFFF5F5F7),
                            const Color(0xFFEDE9FE),
                          ],
                  ),
                ),
                child: Center(
                  child: Text(state.toString()),
                ),
              ),
            ContentLoaded() => Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: state.models.any((element) =>
                        element.route.endsWith('.jpg') ||
                        element.route.endsWith('.png'))
                    ? BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            base +
                                state.models.firstWhere((element) {
                                  final mime =
                                      lookupMimeType(base + element.route);
                                  return mime == 'image/jpeg';
                                }).route,
                          ),
                        ),
                      )
                    : BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  const Color(0xFF0F172A),
                                  const Color(0xFF1E293B),
                                ]
                              : [
                                  const Color(0xFFF5F5F7),
                                  const Color(0xFFEDE9FE),
                                ],
                        ),
                      ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(
                    color: (isDark
                        ? const Color(0xFF0F172A)
                        : Colors.white).withOpacity(0.3),
                    child: Column(
                      children: [
                        // Folder progress indicator
                        if (_hasMediaFiles(state.models))
                          _FolderProgressIndicator(
                            models: state.models,
                            base: base,
                            isDark: isDark,
                          ),
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                              bottom: 20,
                            ),
                            itemBuilder: (context, index) {
                              return ListItem(
                                model: state.models[index],
                                base: base,
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: state.models.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          },
        );
      },
    );
  }

  Future _search(BuildContext context, ContentLoaded state) async {
    return showSearch(
      context: context,
      delegate: ContentSearchDelegate(state.models),
    ).then((value) {
      if (value != null) {
        final model = value;
        if (!model.isFile) {
          ContentRoute(
            title: Uri.decodeFull(model.route.split('/').last),
            base: base,
            url: base + model.route,
            // ignore: use_build_context_synchronously
          ).push(context);
        } else {
          // play video
          final url = base + model.route;
          print(url);
          // Share.share(url);
          // context.router.push(
          //   VideoPlayerRoute(
          //     url: url,
          //     title: Uri.decodeFull(model.route.split('/').last),
          //   ),
          // );
        }
      }
    });
  }

  /// Check if folder contains media files
  bool _hasMediaFiles(List models) {
    return models.any((model) {
      if (!model.isFile) return false;
      final fileName = model.route.toLowerCase();
      return _isMediaFile(fileName);
    });
  }

  /// Check if a file is a media file (video or audio)
  bool _isMediaFile(String fileName) {
    return fileName.endsWith('.mp4') ||
        fileName.endsWith('.mkv') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.webm') ||
        fileName.endsWith('.mp3') ||
        fileName.endsWith('.wav') ||
        fileName.endsWith('.flac') ||
        fileName.endsWith('.m4a') ||
        fileName.endsWith('.aac') ||
        fileName.endsWith('.ogg');
  }

  /// Get media files from folder contents
  List _getMediaFiles(List models) {
    return models.where((model) {
      if (!model.isFile) return false;
      return _isMediaFile(model.route.toLowerCase());
    }).toList();
  }

  /// Convert ClickableModel to PlaylistItem
  PlaylistItem _toPlaylistItem(dynamic model) {
    final url = base + model.route;
    final mimeType = lookupMimeType(url) ?? 'video/mp4';
    final title = Uri.decodeFull(model.route.split('/').last);

    return PlaylistItem(
      title: title,
      url: url,
      mimeType: mimeType,
    );
  }

  /// Play all media files in playlist mode
  void _playAllMedia(BuildContext context, ContentLoaded state) {
    final mediaFiles = _getMediaFiles(state.models);

    if (mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media files found in this folder')),
      );
      return;
    }

    // Convert to playlist items
    final playlistItems = mediaFiles.map(_toPlaylistItem).toList();

    // Create playlist cubit
    final playlistCubit = PlaylistCubit();
    playlistCubit.loadPlaylist(playlistItems);
    playlistCubit.play();

    // Navigate to player with playlist using Navigator directly
    // (can't use auto_route because playlistCubit is not serializable)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          url: playlistItems.first.url,
          title: playlistItems.first.title,
          playlistCubit: playlistCubit,
        ),
      ),
    );
  }

  /// Share playlist as M3U file
  Future<void> _sharePlaylist(BuildContext context, ContentLoaded state) async {
    final mediaFiles = _getMediaFiles(state.models);

    if (mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media files found in this folder')),
      );
      return;
    }

    try {
      // Convert to playlist items
      final playlistItems = mediaFiles.map(_toPlaylistItem).toList();

      // Generate M3U file
      final generator = M3uGenerator();
      final playlistName = Uri.decodeFull(url.split('/').last);
      final m3uPath = await generator.generateM3uFile(playlistName, playlistItems);

      // Share the M3U file
      final result = await Share.shareXFiles(
        [XFile(m3uPath)],
        subject: '$playlistName Playlist',
        text: 'Playlist with ${playlistItems.length} items',
      );

      if (result.status == ShareResultStatus.success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist shared successfully')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing playlist: $e')),
      );
    }
  }

  /// Open playlist with MPV player (desktop only)
  Future<void> _openWithMpv(BuildContext context, ContentLoaded state) async {
    final mediaFiles = _getMediaFiles(state.models);

    if (mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media files found in this folder')),
      );
      return;
    }

    try {
      // Convert to playlist items
      final playlistItems = mediaFiles.map(_toPlaylistItem).toList();

      // Generate M3U file
      final generator = M3uGenerator();
      final playlistName = Uri.decodeFull(url.split('/').last);
      final m3uPath = await generator.generateM3uFile(playlistName, playlistItems);

      // Launch MPV with the playlist
      final result = await Process.start('mpv', [m3uPath]);

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening playlist with MPV (${playlistItems.length} items)'),
        ),
      );

      // Listen to process output for debugging (optional)
      result.stdout.listen((data) {
        // MPV output - can be logged if needed
      });

      result.stderr.listen((data) {
        // MPV errors - can be logged if needed
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening MPV: $e\nMake sure MPV is installed and in PATH'),
        ),
      );
    }
  }

  /// Download all media files in the folder
  Future<void> _downloadAllMedia(BuildContext context, ContentLoaded state) async {
    final mediaFiles = _getMediaFiles(state.models);

    if (mediaFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No media files found in this folder')),
      );
      return;
    }

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DownloadProgressDialog(
        files: mediaFiles,
        base: base,
      ),
    );
  }

  /// Bookmark the current folder
  Future<void> _bookmarkFolder(BuildContext context) async {
    final folderName = Uri.decodeFull(url.split('/').last);

    // Show dialog to get bookmark name
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _BookmarkDialog(defaultName: folderName),
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      final bookmarkManager = BookmarkManager();
      await bookmarkManager.init();

      final success = await bookmarkManager.addBookmark(
        name: name.trim(),
        server: base,
        url: url,
      );

      if (success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bookmarked as "$name"')),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark already exists')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating bookmark: $e')),
      );
    }
  }

  /// Export video progress to a file
  Future<void> _exportProgress(BuildContext context) async {
    try {
      final progressManager = VideoProgressManager();
      await progressManager.init();

      // Get stats first
      final stats = await progressManager.getExportStats();

      if (stats['totalVideos'] == 0) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No progress data to export')),
        );
        return;
      }

      // Show export dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Export Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Export your video progress data?'),
              const SizedBox(height: 16),
              Text('Total videos: ${stats['totalVideos']}'),
              Text('Completed: ${stats['completedVideos']}'),
              Text('In progress: ${stats['inProgressVideos']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Export'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Export progress
      final filePath = await progressManager.exportProgress();

      if (filePath == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export progress')),
        );
        return;
      }

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Video Progress Export',
        text: 'Video progress data exported on ${DateTime.now().toString().split('.')[0]}',
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress exported successfully')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting progress: $e')),
      );
    }
  }

  /// Import video progress from a file
  Future<void> _importProgress(BuildContext context) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid file selected')),
        );
        return;
      }

      // Ask for import mode
      final mergeMode = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Import Mode'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How would you like to import?'),
              SizedBox(height: 8),
              Text(
                'Merge: Keep existing progress, only add new or newer entries',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                'Replace: Overwrite all existing progress',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Replace'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Merge'),
            ),
          ],
        ),
      );

      if (mergeMode == null) return;

      // Import progress
      final progressManager = VideoProgressManager();
      await progressManager.init();

      final importResult = await progressManager.importProgress(
        filePath,
        mergeMode: mergeMode,
      );

      if (!importResult.success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${importResult.error}')),
        );
        return;
      }

      // Show results
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Import Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New items: ${importResult.itemsImported}'),
              Text('Updated items: ${importResult.itemsUpdated}'),
              Text('Skipped items: ${importResult.itemsSkipped}'),
              const SizedBox(height: 8),
              Text(
                'Total processed: ${importResult.totalProcessed}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing progress: $e')),
      );
    }
  }

  /// Show progress statistics
  Future<void> _showProgressStats(BuildContext context) async {
    try {
      final progressManager = VideoProgressManager();
      await progressManager.init();

      final stats = await progressManager.getExportStats();

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.blue),
              SizedBox(width: 8),
              Text('Progress Statistics'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatRow(
                icon: Icons.video_library_rounded,
                label: 'Total tracked videos',
                value: '${stats['totalVideos']}',
              ),
              const SizedBox(height: 8),
              _StatRow(
                icon: Icons.check_circle_rounded,
                label: 'Completed',
                value: '${stats['completedVideos']}',
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              _StatRow(
                icon: Icons.play_circle_rounded,
                label: 'In progress',
                value: '${stats['inProgressVideos']}',
                color: Colors.orange,
              ),
              if (stats['totalVideos'] > 0) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Completion rate: ${((stats['completedVideos'] / stats['totalVideos']) * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading statistics: $e')),
      );
    }
  }
}

/// Dialog for download progress
class _DownloadProgressDialog extends StatefulWidget {
  final List<dynamic> files;
  final String base;

  const _DownloadProgressDialog({
    required this.files,
    required this.base,
  });

  @override
  State<_DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  int currentIndex = 0;
  double currentProgress = 0.0;
  bool isDownloading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    final downloadManager = DownloadManager();

    try {
      await downloadManager.downloadFiles(
        files: widget.files.cast<ClickableModel>(),
        onProgress: (index, progress) {
          if (mounted) {
            setState(() {
              currentIndex = index;
              currentProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          isDownloading = false;
        });

        // Auto-close after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isDownloading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFiles = widget.files.length;
    final overallProgress = totalFiles > 0
        ? (currentIndex + currentProgress) / totalFiles
        : 0.0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Downloading Files'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDownloading) ...[
            Text(
              'File ${currentIndex + 1} of $totalFiles',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: currentProgress),
            const SizedBox(height: 16),
            Text(
              'Overall Progress',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: overallProgress),
          ] else if (errorMessage != null) ...[
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $errorMessage'),
          ] else ...[
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text('All files downloaded successfully!'),
          ],
        ],
      ),
      actions: [
        if (!isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
      ],
    );
  }
}

/// Dialog for adding bookmark
class _BookmarkDialog extends StatefulWidget {
  final String defaultName;

  const _BookmarkDialog({required this.defaultName});

  @override
  State<_BookmarkDialog> createState() => _BookmarkDialogState();
}

class _BookmarkDialogState extends State<_BookmarkDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Bookmark Folder'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Bookmark Name',
          hintText: 'Enter a name for this bookmark',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Folder progress indicator widget
class _FolderProgressIndicator extends StatefulWidget {
  final List models;
  final String base;
  final bool isDark;

  const _FolderProgressIndicator({
    required this.models,
    required this.base,
    required this.isDark,
  });

  @override
  State<_FolderProgressIndicator> createState() => _FolderProgressIndicatorState();
}

class _FolderProgressIndicatorState extends State<_FolderProgressIndicator> {
  final VideoProgressManager _progressManager = VideoProgressManager();
  FolderProgress? _folderProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolderProgress();
  }

  Future<void> _loadFolderProgress() async {
    await _progressManager.init();

    // Get all video URLs in this folder
    final videoUrls = widget.models
        .where((model) => model.isFile && _isMediaFile(model.route.toLowerCase()))
        .map((model) => widget.base + model.route)
        .toList()
        .cast<String>();

    if (videoUrls.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final progress = await _progressManager.getFolderProgress(videoUrls);

    if (mounted) {
      setState(() {
        _folderProgress = progress;
        _isLoading = false;
      });
    }
  }

  bool _isMediaFile(String fileName) {
    return fileName.endsWith('.mp4') ||
        fileName.endsWith('.mkv') ||
        fileName.endsWith('.avi') ||
        fileName.endsWith('.mov') ||
        fileName.endsWith('.webm') ||
        fileName.endsWith('.mp3') ||
        fileName.endsWith('.wav') ||
        fileName.endsWith('.flac') ||
        fileName.endsWith('.m4a') ||
        fileName.endsWith('.aac') ||
        fileName.endsWith('.ogg');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _folderProgress == null || !_folderProgress!.hasAnyProgress) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
        bottom: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
              ? [
                  const Color(0xFF1F2937).withOpacity(0.9),
                  const Color(0xFF374151).withOpacity(0.8),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isDark ? Colors.black : Colors.grey.shade400).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (widget.isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _folderProgress!.isFullyCompleted
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_outline_rounded,
                color: _folderProgress!.isFullyCompleted
                    ? Colors.green
                    : (widget.isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6)),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Folder Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: widget.isDark
                            ? const Color(0xFFF9FAFB)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_folderProgress!.completedVideos} of ${_folderProgress!.totalVideos} videos completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _folderProgress!.isFullyCompleted
                      ? Colors.green.withOpacity(0.15)
                      : (widget.isDark
                          ? const Color(0xFF60A5FA).withOpacity(0.15)
                          : const Color(0xFF3B82F6).withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_folderProgress!.completionPercentage}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _folderProgress!.isFullyCompleted
                        ? Colors.green
                        : (widget.isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _folderProgress!.overallProgress,
              backgroundColor: widget.isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _folderProgress!.isFullyCompleted
                    ? Colors.green
                    : (widget.isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6)),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a statistic row
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? (isDark ? Colors.white70 : Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}

class SearchAction extends Action<SearchIntent> {
  @override
  Object? invoke(SearchIntent intent) {
    return intent.search;
  }
}

class SearchIntent extends Intent {
  final Function(BuildContext, ContentLoaded) search;
  const SearchIntent({
    required this.search,
  });
}
