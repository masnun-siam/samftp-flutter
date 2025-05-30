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
    return Scaffold(
      appBar: AppBar(
        title: Text(HtmlCharacterEntities.decode(
            Uri.decodeFull(widget.title).split('/').last)),
      ),
      body: SafeArea(
        child: Center(
          child: isInitialized
              ? Chewie(controller: chewieController)
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
