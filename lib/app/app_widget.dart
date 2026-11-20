import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/app_dependencies.dart';
import 'package:cars_wheels_app/app/compare/market_compare_market_source.dart';
import 'package:cars_wheels_app/app/market_catalog/market_search_context_source.dart';
import 'package:cars_wheels_app/app/router/app_router_setup.dart';
import 'package:cars_wheels_app/app/search_results/market_search_traits_source.dart';
import 'package:cars_wheels_app/app/search_results/search_card_cubits_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_cubit_factory.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Año con el que arranca cada mercado; si no está disponible, el más reciente.
int preferredYearFor(Market market) => market == Market.mexico
    ? ConueeConfig.defaultYear
    : FuelEconomyConfig.defaultYear;

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
  // Posición de scroll de las secciones; vive tanto como la app.
  final ScrollOffsetStore _scrollOffsets = ScrollOffsetStore();
  AppDependencies get _dependencies => widget.dependencies;

  @override
  void dispose() {
    _router.dispose();
    _dependencies.close();
    super.dispose();
  }

  // Cambio de mercado: listas vacías y recarga en el lugar desde el año por defecto.
  void _onMarketChanged(BuildContext context, MarketState state) {
    context.read<PhotosCubit>().cancelPending();
    context.read<SummariesCubit>().cancelPending();
    context.read<ModelsCubit>().reset();
    unawaited(context.read<CatalogCubit>().reloadForMarket());
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
        RepositoryProvider<ScrollOffsetStore>.value(value: _scrollOffsets),
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
        RepositoryProvider<SearchCardCubitsFactory>.value(
          value: SearchCardCubitsFactory(
            createPhotos: () => PhotosCubit(
              resolveModelPhoto: _dependencies.resolveModelPhotoUseCase,
              cancelPendingPhotos: _dependencies.cancelPendingPhotosUseCase,
              keyBuilder: _dependencies.photoKeyBuilder,
            ),
            createSummaries: () => SummariesCubit(
              resolveGroupSummary: _dependencies.resolveGroupSummaryUseCase,
              cancelPendingSummaries:
                  _dependencies.cancelPendingSummariesUseCase,
              keyBuilder: _dependencies.summaryKeyBuilder,
            ),
          ),
        ),
        RepositoryProvider<PhotoPrefetcher>.value(
          value: const PhotoPrefetcher(),
        ),
        RepositoryProvider<ResolveModelGalleryUseCase>.value(
          value: _dependencies.resolveModelGalleryUseCase,
        ),
        RepositoryProvider<LoadGroupDetailsUseCase>.value(
          value: _dependencies.loadGroupDetailsUseCase,
        ),
        RepositoryProvider<ResolveGroupSafetyUseCase>.value(
          value: _dependencies.resolveGroupSafetyUseCase,
        ),
        // El selector de Comparar crea su propia búsqueda con esta fábrica.
        RepositoryProvider<SearchCubitFactory>.value(
          value: SearchCubitFactory(_dependencies.createIsolatedSearchCubit),
        ),
        RepositoryProvider<CompareVersionLabeler>.value(
          value: _dependencies.compareVersionLabeler,
        ),
        RepositoryProvider<CompareVersionsSource>.value(
          value: _dependencies.compareVersionsSource,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BrandLogosCubit>(
            create: (context) => BrandLogosCubit(
              context.read<BrandLogosRepository>(),
              resolveCommonsLogo: _dependencies.resolveCommonsLogoUseCase,
            )..loadLogos(),
          ),
          BlocProvider<MarketCubit>.value(value: _dependencies.marketCubit),
          BlocProvider<CatalogCubit>(
            create: (context) {
              final market = context.read<MarketCubit>();
              final cubit = CatalogCubit(
                getAvailableYears: context.read<GetAvailableYearsUseCase>(),
                getBrands: context.read<GetBrandsUseCase>(),
                preferredYear: () => preferredYearFor(market.market),
              );
              // Primero se restaura el mercado guardado y luego se carga.
              unawaited(
                market.restore().then((_) {
                  if (!cubit.isClosed) cubit.loadBrands();
                }),
              );
              return cubit;
            },
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
              keyBuilder: _dependencies.summaryKeyBuilder,
            ),
          ),
          // A nivel de app: la consulta y los resultados sobreviven al cambio de sección.
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(
              contextSource: MarketSearchContextSource(
                market: context.read<MarketCubit>(),
                catalog: context.read<CatalogCubit>(),
              ),
              buildIndex: _dependencies.buildSearchIndexUseCase,
              searchWithScope: _dependencies.searchWithScopeUseCase,
              suggestTerms: _dependencies.suggestSearchTermsUseCase,
              searchOtherYears: _dependencies.searchOtherYearsUseCase,
              getBrandGroups: _dependencies.getBrandGroupsUseCase,
              getIndexBrands: _dependencies.getIndexBrandsUseCase,
              addRecent: _dependencies.addRecentSearchUseCase,
              getRecents: _dependencies.getRecentSearchesUseCase,
              removeRecent: _dependencies.removeRecentSearchUseCase,
              clearRecents: _dependencies.clearRecentSearchesUseCase,
              analysisRunner: SearchAnalysisRunner(
                source: MarketSearchTraitsSource(
                  _dependencies.resolveGroupSummaryUseCase,
                ),
              ),
              filterService: const SearchFilterService(
                sortStrategy: AdaptiveSortStrategy<SearchResultEntity>(
                  smallListStrategy: BubbleSortStrategy<SearchResultEntity>(),
                  largeListStrategy: ShellSortStrategy<SearchResultEntity>(),
                ),
              ),
            ),
          ),
          // A nivel de app: la selección sobrevive a Detalle, al selector y a las pestañas.
          BlocProvider<CompareCubit>(
            create: (context) => CompareCubit(
              marketSource: MarketCompareMarketSource(
                context.read<MarketCubit>(),
              ),
              addToCompare: _dependencies.addToCompareUseCase,
              removeFromCompare: _dependencies.removeFromCompareUseCase,
              clearCompare: _dependencies.clearCompareUseCase,
              observeSelection: _dependencies.observeCompareSelectionUseCase,
              updateSlotVersion: _dependencies.updateCompareSlotVersionUseCase,
              replaceSlot: _dependencies.replaceCompareSlotUseCase,
            ),
          ),
          // Datos de cada vehículo del comparador; sigue la selección de arriba.
          BlocProvider<CompareTableCubit>(
            create: (context) => CompareTableCubit(
              compare: context.read<CompareCubit>(),
              vehicleSource: _dependencies.compareVehicleSource,
              safetySource: _dependencies.compareSafetySource,
            ),
          ),
          BlocProvider<LogoPrecacheCubit>(create: (_) => LogoPrecacheCubit()),
          BlocProvider<SectionLoaderCubit>(create: (_) => SectionLoaderCubit()),
        ],
        child: BlocListener<MarketCubit, MarketState>(
          // Solo el cambio hecho por la persona; la restauración inicial no cuenta.
          listenWhen: (previous, current) =>
              previous.isRestored && previous.market != current.market,
          listener: _onMarketChanged,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: AppConfig.showDebugBanner,
            title: AppConfig.appName,
            theme: AppTheme.light,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
