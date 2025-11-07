import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:injectable/injectable.dart';
import 'package:samftp/core/error/failure.dart';
import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';
import 'package:samftp/features/home/domain/repositories/repository.dart';

import '../datasources/datasource.dart';

@LazySingleton(as: Repository)
class RepoImpl implements Repository {
  final DataSource dataSource;

  RepoImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ClickableModel>>> getDocuments(String url) async {
    log(url.toString());
    try {
      final results = await dataSource.getWebsiteFiles(url);
      return Right(results.map((e) {
        return ClickableModel(
          title: HtmlCharacterEntities.decode(e.title ?? ''),
          subtitle: '',
          route: e.url ?? '',
          isFile: !(e.url?.endsWith('/') ?? true),
        );
      }).toList());
    } catch (err) {
      return Left(ServerFailure(err.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getBaseUrl(String url) async {
    log(url.toString());
    try {
      final uri = await dataSource.getBaseUrl(url);
      return Right(uri ?? '');
    } catch (err) {
      return Left(ServerFailure(err.toString()));
    }
  }
}
