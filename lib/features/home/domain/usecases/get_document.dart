import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:samftp/core/core.dart';

import '../entities/clickable_model/clickable_model.dart';
import '../repositories/repository.dart';

@lazySingleton
class GetDocument extends UseCase<List<ClickableModel>, String> {
  final Repository repository;

  GetDocument(this.repository);

  @override
  Future<Either<Failure, List<ClickableModel>>> call(String params) async {
    return await repository.getDocuments(params);
  }
}
