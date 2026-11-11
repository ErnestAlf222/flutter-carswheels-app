import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/app_dependencies.dart';
import 'package:cars_wheels_app/app/router/app_router_setup.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';

/// Widget raíz de la app.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = buildAppRouter();
  final AppDependencies _dependencies = AppDependencies.create();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CatalogRepository>.value(
          value: _dependencies.catalogRepository,
        ),
        RepositoryProvider<GetAvailableYearsUseCase>.value(
          value: _dependencies.getAvailableYearsUseCase,
        ),
        RepositoryProvider<GetLatestYearUseCase>.value(
          value: _dependencies.getLatestYearUseCase,
        ),
        RepositoryProvider<GetBrandsUseCase>.value(
          value: _dependencies.getBrandsUseCase,
        ),
        RepositoryProvider<GetModelsUseCase>.value(
          value: _dependencies.getModelsUseCase,
        ),
        RepositoryProvider<BrandLogosRepository>.value(
          value: _dependencies.brandLogosRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BrandLogosCubit>(
            create: (context) =>
                BrandLogosCubit(context.read<BrandLogosRepository>())
                  ..loadLogos(),
          ),
          BlocProvider<CatalogCubit>(
            create: (context) => CatalogCubit(
              getAvailableYears: context.read<GetAvailableYearsUseCase>(),
              getBrands: context.read<GetBrandsUseCase>(),
            )..loadBrands(),
          ),
          BlocProvider<ModelsCubit>(
            create: (context) =>
                ModelsCubit(getModels: context.read<GetModelsUseCase>()),
          ),
        ],
        child: MaterialApp.router(
          title: AppConfig.appName,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
