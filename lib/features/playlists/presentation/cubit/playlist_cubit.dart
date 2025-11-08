import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samftp/features/playlists/domain/entities/playlist_item.dart';
import 'package:samftp/features/playlists/presentation/cubit/playlist_state.dart';

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit() : super(const PlaylistInitial());

  /// Load a playlist from a list of items
  void loadPlaylist(List<PlaylistItem> items, {int startIndex = 0}) {
    if (items.isEmpty) {
      emit(const PlaylistError('Playlist is empty'));
      return;
    }

    if (startIndex < 0 || startIndex >= items.length) {
      emit(const PlaylistError('Invalid start index'));
      return;
    }

    emit(PlaylistLoaded(
      items: items,
      currentIndex: startIndex,
      isPlaying: false,
    ));
  }

  /// Play the current item
  void play() {
    final currentState = state;
    if (currentState is PlaylistLoaded) {
      emit(currentState.copyWith(isPlaying: true));
    }
  }

  /// Pause the current item
  void pause() {
    final currentState = state;
    if (currentState is PlaylistLoaded) {
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  /// Move to the next item in the playlist
  void next() {
    final currentState = state;
    if (currentState is PlaylistLoaded && currentState.hasNext) {
      emit(currentState.copyWith(
        currentIndex: currentState.currentIndex + 1,
        isPlaying: true,
      ));
    }
  }

  /// Move to the previous item in the playlist
  void previous() {
    final currentState = state;
    if (currentState is PlaylistLoaded && currentState.hasPrevious) {
      emit(currentState.copyWith(
        currentIndex: currentState.currentIndex - 1,
        isPlaying: true,
      ));
    }
  }

  /// Jump to a specific index in the playlist
  void jumpTo(int index) {
    final currentState = state;
    if (currentState is PlaylistLoaded) {
      if (index >= 0 && index < currentState.items.length) {
        emit(currentState.copyWith(
          currentIndex: index,
          isPlaying: true,
        ));
      }
    }
  }

  /// Clear the playlist
  void clear() {
    emit(const PlaylistInitial());
  }

  /// Get the current playlist item
  PlaylistItem? getCurrentItem() {
    final currentState = state;
    if (currentState is PlaylistLoaded) {
      return currentState.currentItem;
    }
    return null;
  }

  /// Check if auto-advance is needed (called when current item finishes)
  void onItemFinished() {
    final currentState = state;
    if (currentState is PlaylistLoaded && currentState.hasNext) {
      next();
    } else if (currentState is PlaylistLoaded) {
      // Playlist finished
      emit(currentState.copyWith(isPlaying: false));
    }
  }
}
