import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:samftp/features/home/domain/usecases/get_document.dart';

import '../../../../core/helper/uri_helper.dart';
import '../../domain/entities/clickable_model/clickable_model.dart';

part 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.getDocument) : super(HomeInitial());

  final GetDocument getDocument;

  void load() async {
    emit(HomeLoding());
    final movies = await getDocument(SamFtpUrls.movie.start);
    final foreign = await getDocument(SamFtpUrls.foreign.start);
    final animation = await getDocument(SamFtpUrls.animation.start);
    final hindi = await getDocument(SamFtpUrls.hindi.start);
    final south = await getDocument(SamFtpUrls.south.start);
    final bangla = await getDocument(SamFtpUrls.bangla.start);
    final series = await getDocument(SamFtpUrls.tv.start);
    final kdramas = await getDocument(SamFtpUrls.kdrama.start);
    final anime = await getDocument(SamFtpUrls.anime.start);
    emit(HomeLoaded(
      movies: movies.getOrElse(() => []),
      series: series.getOrElse(() => []),
      kdramas: kdramas.getOrElse(() => []),
      anime: anime.getOrElse(() => []),
      hindi: hindi.getOrElse(() => []),
      animation: animation.getOrElse(() => []),
      bangla: bangla.getOrElse(() => []),
      south: south.getOrElse(() => []),
      foreign: foreign.getOrElse(() => []),

    ));
  }
}
