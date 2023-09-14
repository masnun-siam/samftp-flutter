// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../core/usecase/get_base_url.dart' as _i6;
import '../features/home/data/datasources/datasource.dart' as _i3;
import '../features/home/data/repositories/repo_impl.dart' as _i5;
import '../features/home/domain/repositories/repository.dart' as _i4;
import '../features/home/domain/usecases/get_document.dart' as _i7;
import '../features/home/presentation/cubit/content_cubit.dart' as _i9;
import '../features/home/presentation/cubit/home_cubit.dart' as _i8;

extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.DataSource>(() => _i3.DataSourceImpl());
    gh.lazySingleton<_i4.Repository>(() => _i5.RepoImpl(gh<_i3.DataSource>()));
    gh.lazySingleton<_i6.GetBaseUrl>(
        () => _i6.GetBaseUrl(gh<_i4.Repository>()));
    gh.lazySingleton<_i7.GetDocument>(
        () => _i7.GetDocument(gh<_i4.Repository>()));
    gh.factory<_i8.HomeCubit>(() => _i8.HomeCubit(gh<_i7.GetDocument>()));
    gh.factory<_i9.ContentCubit>(() => _i9.ContentCubit(
          gh<_i7.GetDocument>(),
          gh<_i6.GetBaseUrl>(),
        ));
    return this;
  }
}
