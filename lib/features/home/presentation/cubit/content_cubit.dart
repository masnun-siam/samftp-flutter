import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:samftp/core/usecase/get_base_url.dart';
import 'package:samftp/features/home/domain/usecases/get_document.dart';

import 'content_state.dart';

@injectable
class ContentCubit extends Cubit<ContentState> {
  ContentCubit(this.getDocument, this.getBaseUrl) : super(ContentInitial());
  final GetDocument getDocument;
  final GetBaseUrl getBaseUrl;

  void load(String uri) async {
    emit(ContentLoading());
    final result = await getDocument(uri);
    final baseUrl = await getBaseUrl(uri);
    result.fold(
      (failure) => emit(ContentError(message: failure.toString())),
      (models) => emit(
          ContentLoaded(models: models, baseUrl: baseUrl.getOrElse(() => ''))),
    );
  }
}
