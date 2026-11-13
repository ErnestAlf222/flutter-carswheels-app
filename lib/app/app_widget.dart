import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/app_dependencies.dart';
import 'package:cars_wheels_app/app/router/app_router_setup.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Widget raíz de la app.
class App extends StatefulWidget {
  const App({required this.dependencies, super.key});

  /// Dependencias ya compuestas; la app las cierra al salir.
  final AppDependencies dependencies;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GoRouter _router = buildAppRouter();
  AppDependencies get _dependencies => widget.dependencies;

  @override
  void dispose() {
    _router.dispose();
    _dependencies.close();
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
        RepositoryProvider<GetBrandsUseCase>.value(
          value: _dependencies.getBrandsUseCase,
        ),
        RepositoryProvider<GetModelGroupsUseCase>.value(
          value: _dependencies.getModelGroupsUseCase,
        ),
        RepositoryProvider<BrandLogosRepository>.value(
          value: _dependencies.brandLogosRepository,
        ),
        RepositoryProvider<VehicleClassTranslator>.value(
          value: _dependencies.vehicleClassTranslator,
        ),
        RepositoryProvider<FuelTypeLabeler>.value(
          value: _dependencies.fuelTypeLabeler,
        ),
        RepositoryProvider<DriveLabeler>.value(
          value: _dependencies.driveLabeler,
        ),
        RepositoryProvider<VersionDescriptorBuilder>.value(
          value: _dependencies.versionDescriptorBuilder,
        ),
        RepositoryProvider<LoadGroupDetailsUseCase>.value(
          value: _dependencies.loadGroupDetailsUseCase,
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
            create: (context) => ModelsCubit(
              getModelGroups: context.read<GetModelGroupsUseCase>(),
            ),
          ),
          BlocProvider<PhotosCubit>(
            create: (_) => PhotosCubit(
              resolveModelPhoto: _dependencies.resolveModelPhotoUseCase,
              cancelPendingPhotos: _dependencies.cancelPendingPhotosUseCase,
              keyBuilder: _dependencies.photoKeyBuilder,
            ),
          ),
          BlocProvider<SummariesCubit>(
            create: (_) => SummariesCubit(
              resolveGroupSummary: _dependencies.resolveGroupSummaryUseCase,
              cancelPendingSummaries:
                  _dependencies.cancelPendingSummariesUseCase,
              keyBuilder: const SummaryKeyBuilder(),
            ),
          ),
          BlocProvider<LogoPrecacheCubit>(create: (_) => LogoPrecacheCubit()),
          BlocProvider<SectionLoaderCubit>(create: (_) => SectionLoaderCubit()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: AppConfig.showDebugBanner,
          title: AppConfig.appName,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}
