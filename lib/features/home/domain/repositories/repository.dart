import 'package:fpdart/fpdart.dart';
import 'package:samftp/core/core.dart';
import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';

abstract class Repository {
  Future<Either<Failure, List<ClickableModel>>> getDocuments(String url);
  Future<Either<Failure, String>> getBaseUrl(String url);
}
