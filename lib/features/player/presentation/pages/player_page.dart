import 'package:auto_route/annotations.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:video_player/video_player.dart';
import 'package:samftp/features/playlists/presentation/cubit/playlist_cubit.dart';
import 'package:samftp/features/playlists/presentation/cubit/playlist_state.dart';

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
  late VideoPlayerController controller;
  late ChewieController chewieController;

  bool isInitialized = false;
  String? currentUrl;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;
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

  void _initializeVideoPlayer(String url) async {
    controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();

    // Listen for video completion
    controller.addListener(_videoListener);

    chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
    );

    setState(() {
      isInitialized = true;
      currentUrl = url;
    });
  }

  void _videoListener() {
    // Check if video finished playing
    if (controller.value.position >= controller.value.duration &&
        controller.value.duration.inSeconds > 0) {
      // Auto-advance to next video in playlist mode
      if (widget.playlistCubit != null) {
        widget.playlistCubit!.onItemFinished();
      }
    }
  }

  void _switchVideo(String newUrl) async {
    setState(() {
      isInitialized = false;
    });

    // Dispose old controllers
    controller.removeListener(_videoListener);
    await controller.dispose();
    await chewieController.dispose();

    // Initialize new video
    _initializeVideoPlayer(newUrl);
  }

  @override
  void dispose() {
    controller.removeListener(_videoListener);
    controller.dispose();
    chewieController.dispose();
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
        actions: isPlaylistMode
            ? [
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
              ]
            : null,
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
              ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: Chewie(controller: chewieController),
                )
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
}
