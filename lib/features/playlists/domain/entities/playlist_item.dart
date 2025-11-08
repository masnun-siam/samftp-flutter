import 'package:equatable/equatable.dart';

class PlaylistItem extends Equatable {
  final String title;
  final String url;
  final String mimeType;
  final Duration? duration;

  const PlaylistItem({
    required this.title,
    required this.url,
    required this.mimeType,
    this.duration,
  });

  bool get isVideo =>
      mimeType.startsWith('video/') ||
      url.endsWith('.mp4') ||
      url.endsWith('.mkv') ||
      url.endsWith('.avi') ||
      url.endsWith('.mov');

  bool get isAudio =>
      mimeType.startsWith('audio/') ||
      url.endsWith('.mp3') ||
      url.endsWith('.wav') ||
      url.endsWith('.flac') ||
      url.endsWith('.m4a') ||
      url.endsWith('.aac');

  @override
  List<Object?> get props => [title, url, mimeType, duration];
}
