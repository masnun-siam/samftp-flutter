import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit() : super(PlayerInitial());
}
