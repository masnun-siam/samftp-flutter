import 'package:auto_route/annotations.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.url, required this.title});
  final String url;
  final String title;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final VideoPlayerController controller;
  late final ChewieController chewieController;

  bool isInitialized = false;
  double aspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() async {
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await controller.initialize();
    chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
    );

    setState(() {
      aspectRatio = controller.value.aspectRatio;
      isInitialized = true;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        title: Text(
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
                  aspectRatio: aspectRatio,
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
