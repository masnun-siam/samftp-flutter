import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'folders_state.dart';

class FoldersCubit extends Cubit<FoldersState> {
  FoldersCubit() : super(FoldersInitial());
}
