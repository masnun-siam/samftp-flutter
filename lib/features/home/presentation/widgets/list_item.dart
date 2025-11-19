import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:external_video_player_launcher/external_video_player_launcher.dart';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:mime/mime.dart';
import 'package:samftp/core/managers/video_progress_manager.dart';
import 'package:samftp/core/routes/app_routes.gr.dart';
import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';
import 'package:share_plus/share_plus.dart';

class ListItem extends StatefulWidget {
  const ListItem({super.key, required this.model, required this.base});

  final ClickableModel model;
  final String base;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final VideoProgressManager _progressManager = VideoProgressManager();
  VideoProgress? _videoProgress;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Load video progress if this is a video file
    if (widget.model.isFile && _isVideoFile(widget.model.route)) {
      _loadVideoProgress();
    }
  }

  Future<void> _loadVideoProgress() async {
    await _progressManager.init();
    final url = widget.base + widget.model.route;
    final progress = await _progressManager.getProgress(url);

    if (mounted) {
      setState(() {
        _videoProgress = progress;
      });
    }
  }

  bool _isVideoFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return extension == 'mp4' ||
        extension == 'mkv' ||
        extension == 'avi' ||
        extension == 'mov' ||
        extension == 'webm';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getFileIcon(String fileName) {
    if (!widget.model.isFile) return Icons.folder_rounded;

    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp4':
      case 'mkv':
      case 'avi':
      case 'mov':
        return Icons.video_library_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getIconColor(String fileName, bool isDark) {
    if (!widget.model.isFile) {
      return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
    }

    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp4':
      case 'mkv':
      case 'avi':
      case 'mov':
        return isDark ? const Color(0xFFF472B6) : const Color(0xFFEC4899);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
      case 'mp3':
      case 'wav':
      case 'flac':
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
      case 'pdf':
        return isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
      default:
        return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileName = (widget.model.title.endsWith('/')
            ? widget.model.title.substring(0, widget.model.title.length - 1)
            : widget.model.title)
        .split('/')
        .last;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1F2937)
                          .withValues(alpha: _isHovering ? 0.9 : 0.7),
                      const Color(0xFF374151)
                          .withValues(alpha: _isHovering ? 0.8 : 0.6),
                    ]
                  : [
                      Colors.white.withValues(alpha: _isHovering ? 0.95 : 0.8),
                      Colors.white.withValues(alpha: _isHovering ? 0.9 : 0.7),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade400)
                    .withValues(alpha: _isHovering ? 0.3 : 0.15),
                blurRadius: _isHovering ? 16 : 8,
                offset: Offset(0, _isHovering ? 6 : 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: _isHovering ? 0.2 : 0.1),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getIconColor(fileName, isDark)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getFileIcon(fileName),
                          color: _getIconColor(fileName, isDark),
                          size: 24,
                        ),
                      ),
                      // Completion badge for videos
                      if (_videoProgress?.isCompleted == true)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fileName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                letterSpacing: -0.3,
                                color: isDark
                                    ? const Color(0xFFF9FAFB)
                                    : const Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Checkmark icon for completed videos
                          if (_videoProgress?.isCompleted == true) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      // Progress bar for videos
                      if (_videoProgress != null &&
                          !_videoProgress!.isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: _videoProgress!.progressPercentage,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getIconColor(fileName, isDark),
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(_videoProgress!.progressPercentage * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: !(Platform.isAndroid || Platform.isIOS)
                      ? widget.model.isFile
                          ? Container(
                              decoration: BoxDecoration(
                                color: (isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: PopupMenuButton(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: isDark
                                      ? const Color(0xFFF9FAFB)
                                      : const Color(0xFF1F2937),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                itemBuilder: (context) {
                                  final isVideoFile =
                                      _isVideoFile(widget.model.route);
                                  return [
                                    PopupMenuItem(
                                      value: 'play',
                                      onTap: () async {
                                        debugPrint(widget.base);
                                        debugPrint(widget.model.toString());
                                        if (!widget.model.isFile) {
                                          context.router.push(
                                            ContentRoute(
                                              title: Uri.decodeFull(widget
                                                  .model.route
                                                  .split('/')
                                                  .last),
                                              base: widget.base,
                                              url: widget.base +
                                                  widget.model.route,
                                            ),
                                          );
                                        } else {
                                          // play video
                                          final url =
                                              widget.base + widget.model.route;
                                          debugPrint(url);
                                          if (isImage(url)) {
                                            final imageProvider =
                                                Image.network(url).image;
                                            showImageViewer(
                                              context,
                                              imageProvider,
                                              backgroundColor: Colors.black,
                                              immersive: true,
                                              useSafeArea: true,
                                            );
                                          } else {
                                            await context.router.push(
                                              VideoPlayerRoute(
                                                url: url,
                                                title: HtmlCharacterEntities
                                                    .decode(widget.model.route
                                                        .split('/')
                                                        .last),
                                              ),
                                            );
                                            // Reload progress when returning from player
                                            await _loadVideoProgress();
                                          }
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                              Icons.play_circle_outline_rounded,
                                              size: 20,
                                              color: isDark
                                                  ? const Color(0xFFF9FAFB)
                                                  : const Color(0xFF1F2937)),
                                          const SizedBox(width: 12),
                                          const Text('Play Locally'),
                                        ],
                                      ),
                                    ),
                                    // Mark as watched/unwatched option for videos
                                    if (isVideoFile)
                                      PopupMenuItem(
                                        value: 'toggle_watched',
                                        onTap: () async {
                                          final url =
                                              widget.base + widget.model.route;
                                          await _progressManager.init();

                                          if (_videoProgress?.isCompleted ==
                                              true) {
                                            await _progressManager
                                                .markAsIncomplete(url);
                                          } else {
                                            // Use existing duration if available, otherwise use a default
                                            final duration =
                                                _videoProgress?.duration ??
                                                    const Duration(hours: 1);
                                            await _progressManager
                                                .markAsCompleted(url, duration);
                                          }

                                          // Reload progress
                                          await _loadVideoProgress();

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  _videoProgress?.isCompleted ==
                                                          true
                                                      ? 'Marked as watched'
                                                      : 'Marked as unwatched',
                                                ),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              _videoProgress?.isCompleted ==
                                                      true
                                                  ? Icons.check_circle_outline
                                                  : Icons.check_circle,
                                              size: 20,
                                              color: isDark
                                                  ? const Color(0xFFF9FAFB)
                                                  : const Color(0xFF1F2937),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _videoProgress?.isCompleted ==
                                                      true
                                                  ? 'Mark as Unwatched'
                                                  : 'Mark as Watched',
                                            ),
                                          ],
                                        ),
                                      ),
                                    PopupMenuItem(
                                      value: 'mpv',
                                      onTap: () {
                                        if (widget.model.isFile) {
                                          final url =
                                              widget.base + widget.model.route;
                                          if (Platform.isMacOS) {
                                            Process.run(
                                              '/opt/homebrew/bin/mpv',
                                              [url],
                                              runInShell: true,
                                            ).then((value) {
                                              if (value.exitCode != 0) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Please install mpv player on your device'),
                                                  ),
                                                );
                                              }
                                            });
                                          } else {
                                            final shareParams = ShareParams(
                                              subject: widget.model.name,
                                              text: widget.model.name,
                                              uri: Uri.parse(url),
                                            );
                                            SharePlus.instance
                                                .share(shareParams);
                                          }
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.video_library_rounded,
                                              size: 20,
                                              color: isDark
                                                  ? const Color(0xFFF9FAFB)
                                                  : const Color(0xFF1F2937)),
                                          const SizedBox(width: 12),
                                          const Text('Play with mpv'),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                              ),
                            )
                          : null
                      : null,
                  onLongPress: () {
                    if (widget.model.isFile) {
                      final url = widget.base + widget.model.route;
                      if (Platform.isAndroid) {
                        // Prepare arguments with title
                        final Map<String, dynamic> args = {
                          "title": (widget.model.title.endsWith('/')
                                  ? widget.model.title.substring(
                                      0, widget.model.title.length - 1)
                                  : widget.model.title)
                              .split('/')
                              .last,
                        };

                        // Pass saved position to external player for auto-resume
                        if (_videoProgress != null &&
                            _videoProgress!.position.inMilliseconds > 0 &&
                            !_videoProgress!.isCompleted) {
                          args["position"] =
                              _videoProgress!.position.inMilliseconds;
                        }

                        ExternalVideoPlayerLauncher.launchOtherPlayer(
                            url, MIME.video, args);
                      } else if (Platform.isMacOS) {
                        // Build mpv command with resume position
                        final List<String> mpvArgs = [url];
                        if (_videoProgress != null &&
                            _videoProgress!.position.inSeconds > 0 &&
                            !_videoProgress!.isCompleted) {
                          mpvArgs.add(
                              '--start=${_videoProgress!.position.inSeconds}');
                        }
                        Process.run('/opt/homebrew/bin/mpv', mpvArgs,
                            runInShell: true);
                      } else {
                        SharePlus.instance.share(
                          ShareParams(
                            uri: Uri.parse(url),
                          ),
                        );
                      }
                    }
                  },
                  onTap: () async {
                    debugPrint(widget.base);
                    debugPrint(widget.model.toString());
                    if (!widget.model.isFile) {
                      context.router.push(
                        ContentRoute(
                          title: Uri.decodeFull(
                              widget.model.route.split('/').last),
                          base: widget.base,
                          url: widget.base + widget.model.route,
                        ),
                      );
                    } else {
                      // play video
                      final url = widget.base + widget.model.route;
                      debugPrint(url);
                      if (isImage(url)) {
                        final imageProvider = Image.network(url).image;
                        showImageViewer(
                          context,
                          imageProvider,
                          backgroundColor: Colors.black,
                          immersive: true,
                          useSafeArea: true,
                        );
                      } else {
                        await context.router.push(
                          VideoPlayerRoute(
                            url: url,
                            title: HtmlCharacterEntities.decode(
                                widget.model.route.split('/').last),
                          ),
                        );
                        // Reload progress when returning from player
                        await _loadVideoProgress();
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isImage(String path) {
    final mimeType = lookupMimeType(path);

    return mimeType?.startsWith('image/') ?? false;
  }
}
