import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:html_character_entities/html_character_entities.dart';

@RoutePage()
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key, required this.url, required this.title})
      : super(key: key);
  final String url;
  final String title;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final _meeduPlayerController = MeeduPlayerController(
    controlsStyle: ControlsStyle.primary,
  );

  @override
  void initState() {
    super.initState();
// The following line will enable the Android and iOS wakelock.

    // Wait until the first render the avoid possible errors when use an context while the view is rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  @override
  void dispose() {
    // The next line disables the wakelock again.
    _meeduPlayerController.dispose(); // release the video player
    super.dispose();
  }

  /// play a video from network
  _init() {
    _meeduPlayerController.setDataSource(
      DataSource(
        type: DataSourceType.network,
        source: widget.url,
      ),
      autoplay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(HtmlCharacterEntities.decode(Uri.decodeFull(widget.title).split('/').last)),
      ),
      body: SafeArea(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: MeeduVideoPlayer(
            controller: _meeduPlayerController,
          ),
        ),
      ),
    );
  }
}
