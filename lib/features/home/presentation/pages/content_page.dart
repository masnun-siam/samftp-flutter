import 'dart:ui';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:samftp/di/di.dart';
import 'package:samftp/features/home/presentation/cubit/content_cubit.dart';
import 'package:samftp/features/home/presentation/widgets/list_item.dart';
import 'package:samftp/features/playlists/domain/entities/playlist_item.dart';
import 'package:samftp/features/playlists/presentation/cubit/playlist_cubit.dart';
import 'package:samftp/features/playlists/data/services/m3u_generator.dart';
import 'package:samftp/features/player/presentation/pages/player_page.dart';
import 'package:samftp/core/managers/bookmark_manager.dart';
import 'package:samftp/core/managers/download_manager.dart';
import 'package:share_plus/share_plus.dart';

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
}

/// Dialog for download progress
class _DownloadProgressDialog extends StatefulWidget {
  final List files;
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
        files: widget.files,
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
