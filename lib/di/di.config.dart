// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../core/usecase/get_base_url.dart' as _i885;
import '../features/home/data/datasources/datasource.dart' as _i650;
import '../features/home/data/repositories/repo_impl.dart' as _i637;
import '../features/home/domain/repositories/repository.dart' as _i967;
import '../features/home/domain/usecases/get_document.dart' as _i599;
import '../features/home/presentation/cubit/content_cubit.dart' as _i857;
import '../features/home/presentation/cubit/home_cubit.dart' as _i1017;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i650.DataSource>(() => _i650.DataSourceImpl());
    gh.lazySingleton<_i967.Repository>(
        () => _i637.RepoImpl(gh<_i650.DataSource>()));
    gh.lazySingleton<_i885.GetBaseUrl>(
        () => _i885.GetBaseUrl(gh<_i967.Repository>()));
    gh.lazySingleton<_i599.GetDocument>(
        () => _i599.GetDocument(gh<_i967.Repository>()));
    gh.factory<_i857.ContentCubit>(() => _i857.ContentCubit(
          gh<_i599.GetDocument>(),
          gh<_i885.GetBaseUrl>(),
        ));
    gh.factory<_i1017.HomeCubit>(
        () => _i1017.HomeCubit(gh<_i599.GetDocument>()));
    return this;
  }
}
