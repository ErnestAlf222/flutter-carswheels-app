import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/app_dependencies.dart';
import 'package:cars_wheels_app/app/compare/market_compare_market_source.dart';
import 'package:cars_wheels_app/app/favorites/favorite_card_cubits.dart';
import 'package:cars_wheels_app/app/market_catalog/market_change_notice.dart';
import 'package:cars_wheels_app/app/market_catalog/market_search_context_source.dart';
import 'package:cars_wheels_app/app/router/app_router_setup.dart';
import 'package:cars_wheels_app/app/search_results/market_search_traits_source.dart';
import 'package:cars_wheels_app/app/search_results/search_card_cubits_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_cubit_factory.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
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
  // Para mostrar el aviso de mercado sobre cualquier pantalla.
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // Posición de scroll de las secciones; vive tanto como la app.
  final ScrollOffsetStore _scrollOffsets = ScrollOffsetStore();
  AppDependencies get _dependencies => widget.dependencies;

  @override
  void initState() {
    super.initState();
    // Al iniciar se borran las fotos de favoritos que ya no son de nadie.
    if (FavoritesConfig.cleanOrphansOnStart) {
      unawaited(_cleanOrphanPhotos());
    }
  }

  Future<void> _cleanOrphanPhotos() async {
    try {
      await _dependencies.cleanOrphanFavoritePhotosUseCase?.call();
    } on Object {
      // Sin limpiar, solo sobran archivos; se vuelve a intentar al siguiente inicio.
    }
  }

  // Vuelve la conexión: cada sección que quedó sin datos se recarga una vez.
  void _restoreAfterReconnect(BuildContext context) {
    context.read<BrandLogosCubit>().restoreAfterReconnect();
    unawaited(context.read<CatalogCubit>().restoreAfterReconnect());
    unawaited(context.read<ModelsCubit>().retry());
    context.read<PhotosCubit>().restoreAfterReconnect();
    context.read<SummariesCubit>().restoreAfterReconnect();
    context.read<SearchCubit>().restoreAfterReconnect();
    context.read<CompareTableCubit>().restoreAfterReconnect();
  }

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
    unawaited(
      _reloadAndAnnounce(
        context.read<CatalogCubit>(),
        context.read<MarketCubit>(),
        state.market,
      ),
    );
  }

  // Recarga el catálogo y avisa con el año que quedó vigente.
  Future<void> _reloadAndAnnounce(
    CatalogCubit catalog,
    MarketCubit marketCubit,
    Market market,
  ) async {
    await catalog.reloadForMarket();
    final messenger = _messengerKey.currentState;
    // Si la persona ya volvió a cambiar, el aviso es del último cambio.
    if (!mounted || catalog.isClosed || messenger == null) return;
    if (marketCubit.market != market) return;
    final loaded = catalog.state;
    final year = loaded is CatalogLoaded
        ? loaded.year
        : preferredYearFor(market);
    final onCompare =
        _router.routeInformationProvider.value.uri.path == RoutesConfig.compare;
    showMarketChangedNotice(
      messenger,
      overlay: _router.routerDelegate.navigatorKey.currentState?.overlay,
      market: market,
      year: year,
      onCompare: onCompare,
    );
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
        // Para que Favoritos y Detalle usen la foto guardada en el teléfono.
        if (_dependencies.favoritePhotoStore case final store?)
          RepositoryProvider<FavoritePhotoStore>.value(value: store),
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
        RepositoryProvider<VehicleSpecSheetBuilder>.value(
          value: VehicleSpecSheetBuilder(
            transmissionLabeler: _dependencies.transmissionLabeler,
            fuelTypeLabeler: _dependencies.fuelTypeLabeler,
            driveLabeler: _dependencies.driveLabeler,
          ),
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
        // Las tarjetas de Favoritos se llenan con lo guardado, sin pedir a la red.
        RepositoryProvider<FavoriteCardCubitsFactory>.value(
          value: FavoriteCardCubitsFactory(
            createPhotos: () => SnapshotPhotosCubit(
              resolveModelPhoto: _dependencies.resolveModelPhotoUseCase,
              cancelPendingPhotos: _dependencies.cancelPendingPhotosUseCase,
              keyBuilder: _dependencies.photoKeyBuilder,
            ),
            createSummaries: () => SnapshotSummariesCubit(
              resolveGroupSummary: _dependencies.resolveGroupSummaryUseCase,
              cancelPendingSummaries:
                  _dependencies.cancelPendingSummariesUseCase,
              keyBuilder: const SummaryKeyBuilder(),
            ),
          ),
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
              fileStore: _dependencies.logoFileStore,
            )..loadLogos(),
          ),
          BlocProvider<MarketCubit>.value(value: _dependencies.marketCubit),
          BlocProvider<ConnectivityCubit>.value(
            value: _dependencies.connectivityCubit,
          ),
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
          // A nivel de app: cualquier corazón consulta y alterna favoritos.
          BlocProvider<FavoritesCubit>(
            create: (_) => FavoritesCubit(
              observeFavorites: _dependencies.observeFavoritesUseCase,
              getFavorites: _dependencies.getFavoritesUseCase,
              toggleFavorite: _dependencies.toggleFavoriteUseCase,
              removeFavorite: _dependencies.removeFavoriteUseCase,
              restoreFavorite: _dependencies.restoreFavoriteUseCase,
              completeSnapshot: _dependencies.completeFavoriteSnapshotUseCase,
              snapshotSource: _dependencies.favoriteSnapshotSource,
              attachPhoto: _dependencies.attachFavoritePhotoUseCase,
              deletePhoto: _dependencies.deleteFavoritePhotoUseCase,
            ),
          ),
          BlocProvider<LogoPrecacheCubit>(
            create: (_) => LogoPrecacheCubit(
              service: LogoPrecacheService(store: _dependencies.logoFileStore),
            ),
          ),
        ],
        child: Builder(
          builder: (context) => ConnectivityLifecycleHost(
            cubit: _dependencies.connectivityCubit,
            child: ConnectivityRestoreListener(
              onRestored: () => _restoreAfterReconnect(context),
              child: BlocListener<MarketCubit, MarketState>(
                // Solo el cambio hecho por la persona; la restauración inicial no cuenta.
                listenWhen: isUserMarketChange,
                listener: _onMarketChanged,
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: AppConfig.showDebugBanner,
                  title: AppConfig.appName,
                  theme: AppTheme.light,
                  routerConfig: _router,
                  scaffoldMessengerKey: _messengerKey,
                  // El mensaje de favoritos va sobre cualquier pantalla, sobre el menú flotante.
                  builder: (context, child) => FavoritesMessageHost(
                    bottomInset: NavConfig.footprint,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
