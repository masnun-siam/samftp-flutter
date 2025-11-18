import 'package:auto_route/annotations.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:samftp/features/playlists/presentation/cubit/playlist_cubit.dart';
import 'package:samftp/features/playlists/presentation/cubit/playlist_state.dart';
import 'package:samftp/core/managers/video_progress_manager.dart';
import 'dart:async';

@RoutePage()
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.url,
    required this.title,
    this.playlistCubit,
  });
  final String url;
  final String title;
  final PlaylistCubit? playlistCubit;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // For mobile (Chewie)
  late vp.VideoPlayerController vpController;
  late ChewieController chewieController;

  // For desktop (media_kit)
  late Player player;
  late VideoController videoController;

  bool isInitialized = false;
  String? currentUrl;

  // Video progress tracking
  final VideoProgressManager _progressManager = VideoProgressManager();
  Timer? _progressTimer;
  bool _isCompleted = false;
  Duration? _savedPosition;
  bool _hasShownResumeDialog = false;

  // Check if running on desktop
  bool get isDesktop => !kIsWeb && (
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux
  );

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;
    _initializeProgressManager();
    _initializeVideoPlayer(widget.url);

    // Listen to playlist changes if in playlist mode
    if (widget.playlistCubit != null) {
      widget.playlistCubit!.stream.listen((state) {
        if (state is PlaylistLoaded) {
          final newUrl = state.currentItem.url;
          if (newUrl != currentUrl) {
            _switchVideo(newUrl);
          }
        }
      });
    }
  }

  /// Initialize progress manager and load saved position
  Future<void> _initializeProgressManager() async {
    await _progressManager.init();
    final progress = await _progressManager.getProgress(widget.url);

    if (progress != null) {
      _savedPosition = progress.position;
      _isCompleted = progress.isCompleted;
    }
  }

  void _initializeVideoPlayer(String url) async {
    if (isDesktop) {
      // Initialize media_kit for desktop
      player = Player();
      videoController = VideoController(player);

      await player.open(Media(url));

      // Show resume dialog if saved position exists and not already shown
      if (_savedPosition != null && _savedPosition!.inSeconds > 5 && !_hasShownResumeDialog) {
        _hasShownResumeDialog = true;
        // Pause the player until user decides
        await player.pause();
        
        // Show resume dialog after a short delay to ensure player is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResumeDialog();
        });
      }

      // Listen for video completion on desktop
      player.stream.completed.listen((completed) {
        if (completed) {
          _onVideoCompleted();
          if (widget.playlistCubit != null) {
            widget.playlistCubit!.onItemFinished();
          }
        }
      });

      // Start progress tracking for desktop
      _startProgressTracking();
    } else {
      // Initialize Chewie for mobile
      vpController = vp.VideoPlayerController.networkUrl(Uri.parse(url));
      await vpController.initialize();

      // Show resume dialog if saved position exists and not already shown
      if (_savedPosition != null && _savedPosition!.inSeconds > 5 && !_hasShownResumeDialog) {
        _hasShownResumeDialog = true;
        // Don't auto-play if we need to show resume dialog
        
        // Show resume dialog after a short delay to ensure player is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResumeDialog();
        });
      }

      // Listen for video completion
      vpController.addListener(_videoListener);

      chewieController = ChewieController(
        videoPlayerController: vpController,
        autoPlay: _savedPosition == null || _savedPosition!.inSeconds <= 5, // Only auto-play if no resume needed
        looping: false,
        allowedScreenSleep: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
      );

      // Start progress tracking for mobile
      _startProgressTracking();
    }

    setState(() {
      isInitialized = true;
      currentUrl = url;
    });
  }

  /// Show resume dialog to user
  Future<void> _showResumeDialog() async {
    if (!mounted) return;

    final savedPos = _savedPosition!;
    final hours = savedPos.inHours;
    final minutes = savedPos.inMinutes.remainder(60);
    final seconds = savedPos.inSeconds.remainder(60);
    
    String timeString;
    if (hours > 0) {
      timeString = '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Resume playback?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        content: Text(
          'This video was previously played. Would you like to resume from $timeString?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Start from beginning',
              style: TextStyle(fontSize: 15),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Resume',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result == true) {
      // Resume from saved position
      if (isDesktop) {
        await player.seek(_savedPosition!);
        await player.play();
      } else {
        await vpController.seekTo(_savedPosition!);
        await vpController.play();
      }
    } else {
      // Start from beginning
      if (isDesktop) {
        await player.seek(Duration.zero);
        await player.play();
      } else {
        await vpController.seekTo(Duration.zero);
        await vpController.play();
      }
    }
  }

  void _videoListener() {
    // Check if video finished playing (mobile only)
    if (vpController.value.position >= vpController.value.duration &&
        vpController.value.duration.inSeconds > 0) {
      _onVideoCompleted();
      // Auto-advance to next video in playlist mode
      if (widget.playlistCubit != null) {
        widget.playlistCubit!.onItemFinished();
      }
    }
  }

  /// Start tracking video progress periodically
  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _saveCurrentProgress();
    });
  }

  /// Save current playback progress
  Future<void> _saveCurrentProgress() async {
    if (currentUrl == null) return;

    Duration position;
    Duration duration;

    if (isDesktop) {
      position = player.state.position;
      duration = player.state.duration;
    } else {
      if (!vpController.value.isInitialized) return;
      position = vpController.value.position;
      duration = vpController.value.duration;
    }

    // Only save if we have valid duration
    if (duration.inMilliseconds > 0) {
      await _progressManager.saveProgress(
        videoUrl: currentUrl!,
        position: position,
        duration: duration,
      );

      // Check if we should auto-complete at 85%
      final progressPercentage = position.inMilliseconds / duration.inMilliseconds;
      if (progressPercentage >= 0.85 && !_isCompleted) {
        setState(() {
          _isCompleted = true;
        });
        // Show completion notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video marked as completed'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// Handle video completion
  void _onVideoCompleted() {
    if (currentUrl == null) return;

    Duration duration;
    if (isDesktop) {
      duration = player.state.duration;
    } else {
      duration = vpController.value.duration;
    }

    // Mark as completed
    _progressManager.markAsCompleted(currentUrl!, duration);
    setState(() {
      _isCompleted = true;
    });
  }

  /// Manually mark video as completed
  Future<void> _markAsCompleted() async {
    if (currentUrl == null) return;

    Duration duration;
    if (isDesktop) {
      duration = player.state.duration;
    } else {
      duration = vpController.value.duration;
    }

    await _progressManager.markAsCompleted(currentUrl!, duration);
    setState(() {
      _isCompleted = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video marked as completed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Mark video as incomplete
  Future<void> _markAsIncomplete() async {
    if (currentUrl == null) return;

    await _progressManager.markAsIncomplete(currentUrl!);
    setState(() {
      _isCompleted = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video marked as incomplete'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _switchVideo(String newUrl) async {
    // Save progress before switching
    await _saveCurrentProgress();

    setState(() {
      isInitialized = false;
    });

    // Cancel progress timer
    _progressTimer?.cancel();

    // Reset resume dialog flag for new video
    _hasShownResumeDialog = false;

    if (isDesktop) {
      // Stop the current player before switching
      await player.stop();
      // Switch video on desktop
      await player.open(Media(newUrl));
    } else {
      // Dispose old controllers on mobile
      vpController.removeListener(_videoListener);
      await vpController.dispose();
      chewieController.dispose();
    }

    // Load progress for new video
    final progress = await _progressManager.getProgress(newUrl);
    _savedPosition = progress?.position;
    _isCompleted = progress?.isCompleted ?? false;

    // Initialize new video
    _initializeVideoPlayer(newUrl);
  }

  @override
  void dispose() {
    // Save progress before disposing
    _saveCurrentProgress();

    // Cancel progress tracking timer
    _progressTimer?.cancel();

    if (isDesktop) {
      player.dispose();
    } else {
      vpController.removeListener(_videoListener);
      vpController.dispose();
      chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaylistMode = widget.playlistCubit != null;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: IconButton(
            style: TextButton.styleFrom(
              iconColor: Colors.white,
              padding: const EdgeInsets.all(8),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
        ),
        title: isPlaylistMode
            ? BlocBuilder<PlaylistCubit, PlaylistState>(
                bloc: widget.playlistCubit,
                builder: (context, state) {
                  if (state is PlaylistLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          HtmlCharacterEntities.decode(
                              Uri.decodeFull(state.currentItem.title)
                                  .split('/')
                                  .last),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: -0.3,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Playlist: ${state.currentIndex + 1} / ${state.items.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(
                    HtmlCharacterEntities.decode(
                        Uri.decodeFull(widget.title).split('/').last),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              )
            : Text(
                HtmlCharacterEntities.decode(
                    Uri.decodeFull(widget.title).split('/').last),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: -0.3,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          // Mark as completed button
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: IconButton(
              style: TextButton.styleFrom(
                iconColor: Colors.white,
                padding: const EdgeInsets.all(8),
              ),
              onPressed: () {
                if (_isCompleted) {
                  _markAsIncomplete();
                } else {
                  _markAsCompleted();
                }
              },
              icon: Icon(
                _isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                size: 24,
                color: _isCompleted ? Colors.green : Colors.white,
              ),
              tooltip: _isCompleted ? 'Mark as incomplete' : 'Mark as completed',
            ),
          ),
          if (isPlaylistMode) ...[
            BlocBuilder<PlaylistCubit, PlaylistState>(
              bloc: widget.playlistCubit,
              builder: (context, state) {
                if (state is PlaylistLoaded) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Previous button
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: IconButton(
                          style: TextButton.styleFrom(
                            iconColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: state.hasPrevious
                              ? () => widget.playlistCubit!.previous()
                              : null,
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            size: 24,
                            color: state.hasPrevious
                                ? Colors.white
                                : Colors.white38,
                          ),
                        ),
                      ),
                      // Next button
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: IconButton(
                          style: TextButton.styleFrom(
                            iconColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: state.hasNext
                              ? () => widget.playlistCubit!.next()
                              : null,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            size: 24,
                            color: state.hasNext
                                ? Colors.white
                                : Colors.white38,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: Center(
          child: isInitialized
              ? isDesktop
                  ? _buildDesktopPlayer()
                  : _buildMobilePlayer()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Loading video...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDesktopPlayer() {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        buttonBarButtonSize: 28.0,
        buttonBarButtonColor: Colors.white,
        seekBarThumbColor: Theme.of(context).colorScheme.primary,
        seekBarPositionColor: Theme.of(context).colorScheme.primary,
        volumeBarThumbColor: Theme.of(context).colorScheme.primary,
        volumeBarActiveColor: Theme.of(context).colorScheme.primary,
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(
        buttonBarButtonSize: 32.0,
        buttonBarButtonColor: Colors.white,
      ),
      child: Video(
        controller: videoController,
        controls: MaterialDesktopVideoControls,
      ),
    );
  }

  Widget _buildMobilePlayer() {
    return AspectRatio(
      aspectRatio: vpController.value.aspectRatio,
      child: Chewie(controller: chewieController),
    );
  }
}
