import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:samftp/core/core.dart';

import '../../features/home/domain/repositories/repository.dart';

@lazySingleton
class GetBaseUrl extends UseCase<String, String> {
  final Repository repository;

  GetBaseUrl(this.repository);
  @override
  Future<Either<Failure, String>> call(String params) {
    return repository.getBaseUrl(params);
  }
}
