import 'package:equatable/equatable.dart';
import 'package:samftp/features/playlists/domain/entities/playlist_item.dart';

abstract class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object?> get props => [];
}

class PlaylistInitial extends PlaylistState {
  const PlaylistInitial();
}

class PlaylistLoaded extends PlaylistState {
  final List<PlaylistItem> items;
  final int currentIndex;
  final bool isPlaying;

  const PlaylistLoaded({
    required this.items,
    required this.currentIndex,
    this.isPlaying = false,
  });

  PlaylistItem get currentItem => items[currentIndex];

  bool get hasNext => currentIndex < items.length - 1;
  bool get hasPrevious => currentIndex > 0;

  PlaylistLoaded copyWith({
    List<PlaylistItem>? items,
    int? currentIndex,
    bool? isPlaying,
  }) {
    return PlaylistLoaded(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [items, currentIndex, isPlaying];
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object?> get props => [message];
}
