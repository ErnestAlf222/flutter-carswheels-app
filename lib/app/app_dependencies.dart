import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/app/market_catalog/market_get_available_years_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_get_brands_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_get_model_groups_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_load_group_details_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_resolve_group_summary_usecase.dart';
import 'package:cars_wheels_app/app/market_catalog/market_search_catalog_source.dart';
import 'package:cars_wheels_app/app/market_catalog/market_summary_key_builder.dart';
import 'package:cars_wheels_app/app/compare/compare_group_details_loader.dart';
import 'package:cars_wheels_app/app/compare/compare_version_namer.dart';
import 'package:cars_wheels_app/app/compare/market_compare_version_labeler.dart';
import 'package:cars_wheels_app/app/compare/market_compare_safety_source.dart';
import 'package:cars_wheels_app/app/compare/market_compare_vehicle_source.dart';
import 'package:cars_wheels_app/app/compare/market_compare_versions_source.dart';
import 'package:cars_wheels_app/app/favorites/market_favorite_snapshot_source.dart';
import 'package:cars_wheels_app/app/search_results/market_search_traits_source.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Construye las dependencias de la app en un solo lugar.
class AppDependencies {
  AppDependencies._({
    required this.marketCubit,
    required this.networkSignals,
    required this.connectivityCubit,
    this.logoFileStore,
    this.favoritePhotoStore,
    this.attachFavoritePhotoUseCase,
    this.measureFavoritePhotoUseCase,
    this.deleteFavoritePhotoUseCase,
    this.cleanOrphanFavoritePhotosUseCase,
    required this.summaryKeyBuilder,
    required this.catalogRepository,
    required this.getAvailableYearsUseCase,
    required this.getBrandsUseCase,
    required this.getModelGroupsUseCase,
    required this.brandLogosRepository,
    this.resolveCommonsLogoUseCase,
    required this.getModelPhotoUseCase,
    required this.resolveModelPhotoUseCase,
    required this.getModelGalleryUseCase,
    required this.resolveModelGalleryUseCase,
    required this.cancelPendingPhotosUseCase,
    required this.photoKeyBuilder,
    required this.getGroupSummaryUseCase,
    required this.resolveGroupSummaryUseCase,
    required this.cancelPendingSummariesUseCase,
    required this.getGroupOptionsUseCase,
    required this.resolveVehicleDetailUseCase,
    required this.vehicleClassTranslator,
    required this.driveLabeler,
    required this.fuelTypeLabeler,
    required this.transmissionLabeler,
    required this.versionDescriptorBuilder,
    required this.defaultVersionSelector,
    required this.loadGroupDetailsUseCase,
    required this.resolveGroupSafetyUseCase,
    required this.getMxYearsUseCase,
    required this.getMxBrandsUseCase,
    required this.getMxModelGroupsUseCase,
    required this.getMxVersionsUseCase,
    required this.buildSearchIndexUseCase,
    required this.searchWithScopeUseCase,
    required this.suggestSearchTermsUseCase,
    required this.searchOtherYearsUseCase,
    required this.getBrandGroupsUseCase,
    required this.getIndexBrandsUseCase,
    required this.addRecentSearchUseCase,
    required this.getRecentSearchesUseCase,
    required this.removeRecentSearchUseCase,
    required this.clearRecentSearchesUseCase,
    required this.createIsolatedSearchCubit,
    required this.addToCompareUseCase,
    required this.removeFromCompareUseCase,
    required this.clearCompareUseCase,
    required this.observeCompareSelectionUseCase,
    required this.updateCompareSlotVersionUseCase,
    required this.replaceCompareSlotUseCase,
    required this.compareVehicleSource,
    required this.compareSafetySource,
    required this.compareVersionsSource,
    required this.compareVersionLabeler,
    required this.observeFavoritesUseCase,
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.restoreFavoriteUseCase,
    required this.completeFavoriteSnapshotUseCase,
    required this.favoriteSnapshotSource,
    required this.commonsQueue,
    required this.fuelEconomyQueue,
    required this.nhtsaQueue,
    required this.conueeQueue,
    required this.closeStorage,
  });

  /// Compone la app con la caché de fotos guardada en la instancia de Isar.
  factory AppDependencies.withIsar(Isar isar, {Directory? filesRoot}) {
    return AppDependencies.create(
      filesRoot: filesRoot,
      groupOptionsCache: IsarGroupOptionsCacheDatasource(isar),
      photoCache: IsarPhotoCacheDatasource(isar),
      galleryCache: IsarGalleryCacheDatasource(isar),
      summaryCache: IsarSummaryCacheDatasource(isar),
      detailCache: IsarVehicleDetailCacheDatasource(isar),
      safetyCache: IsarSafetyCacheDatasource(isar),
      mexicoCatalogCache: IsarMexicoCatalogCacheDatasource(isar),
      marketPreference: IsarMarketPreferenceDatasource(isar),
      recentSearches: IsarRecentSearchesDatasource(isar),
      compareSelection: IsarCompareSelectionDatasource(
        isar,
        clock: DateTime.now,
      ),
      favorites: IsarFavoritesDatasource(isar),
      commonsLogoCache: IsarCommonsLogoCacheDatasource(isar),
      closeStorage: () => IsarDatabase.close(isar),
    );
  }

  /// Compone la app con clientes reales y la caché de fotos dada.
  factory AppDependencies.create({
    required PhotoCacheDatasource photoCache,
    required GalleryCacheDatasource galleryCache,
    required SummaryCacheDatasource summaryCache,
    required VehicleDetailCacheDatasource detailCache,
    required SafetyCacheDatasource safetyCache,
    required MexicoCatalogCacheDatasource mexicoCatalogCache,
    required MarketPreferenceDatasource marketPreference,
    required RecentSearchesDatasource recentSearches,
    required CompareSelectionDatasource compareSelection,
    required FavoritesDatasource favorites,
    CommonsLogoCacheDatasource? commonsLogoCache,
    GroupOptionsCacheDatasource? groupOptionsCache,
    Directory? filesRoot,
    Future<void> Function()? closeStorage,
  }) {
    // Todas las peticiones reportan aquí si hay o no conexión.
    final signals = NetworkSignals();
    final fuelEconomyDio = ApiClientFactory.create(
      signals: signals,
      baseUrl: ApiConfig.fuelEconomyBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.fuelEconomyUserAgent,
      sourceLabel: FuelEconomyConfig.fuelEconomySourceLabel,
    );
    final logosDio = ApiClientFactory.create(
      signals: signals,
      baseUrl: LogosConfig.logosBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.logosUserAgent,
      sourceLabel: LogosConfig.logosSourceLabel,
    );
    final commonsDio = ApiClientFactory.create(
      signals: signals,
      baseUrl: ApiConfig.commonsApiUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.commonsUserAgent,
      sourceLabel: PhotosConfig.commonsSourceLabel,
    );
    final nhtsaApiDio = ApiClientFactory.create(
      signals: signals,
      baseUrl: ApiConfig.nhtsaApiBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.nhtsaUserAgent,
      sourceLabel: SafetyConfig.nhtsaSourceLabel,
    );
    final nhtsaVpicDio = ApiClientFactory.create(
      signals: signals,
      baseUrl: ApiConfig.nhtsaVpicBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.nhtsaUserAgent,
      sourceLabel: SafetyConfig.nhtsaSourceLabel,
    );
    final conueeDio = ApiClientFactory.create(
      signals: signals,
      baseUrl: ApiConfig.conueeApiBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.conueeUserAgent,
      sourceLabel: ConueeConfig.sourceLabel,
    );
    // La sonda va aparte: sin registro ni señales, para no contarse a sí misma.
    final probeDio = ApiClientFactory.create(
      baseUrl: ApiConfig.fuelEconomyBaseUrl,
      acceptHeaderValue: NetworkConfig.jsonAcceptHeaderValue,
      userAgent: UserAgentsConfig.fuelEconomyUserAgent,
      sourceLabel: FuelEconomyConfig.fuelEconomySourceLabel,
      enableLogging: false,
    );
    final photoDio = ApiClientFactory.create(
      baseUrl: ApiConfig.commonsApiUrl,
      acceptHeaderValue: NetworkConfig.imageAcceptHeaderValue,
      userAgent: UserAgentsConfig.commonsUserAgent,
      sourceLabel: PhotosConfig.commonsSourceLabel,
      signals: signals,
    );
    return AppDependencies.fromDio(
      fuelEconomyDio,
      logosDio,
      commonsDio,
      nhtsaApiDio,
      nhtsaVpicDio,
      conueeDio,
      photoCache,
      galleryCache,
      summaryCache,
      detailCache,
      safetyCache,
      mexicoCatalogCache,
      marketPreference,
      recentSearches,
      compareSelection,
      favorites,
      commonsLogoCache: commonsLogoCache,
      groupOptionsCache: groupOptionsCache,
      filesRoot: filesRoot,
      networkSignals: signals,
      probeDio: probeDio,
      photoDio: photoDio,
      closeStorage: closeStorage,
    );
  }

  /// Compone todo sobre un Dio dado.
  factory AppDependencies.fromDio(
    Dio fuelEconomyDio,
    Dio logosDio,
    Dio commonsDio,
    Dio nhtsaApiDio,
    Dio nhtsaVpicDio,
    Dio conueeDio,
    PhotoCacheDatasource photoCache,
    GalleryCacheDatasource galleryCache,
    SummaryCacheDatasource summaryCache,
    VehicleDetailCacheDatasource detailCache,
    SafetyCacheDatasource safetyCache,
    MexicoCatalogCacheDatasource mexicoCatalogCache,
    MarketPreferenceDatasource marketPreference,
    RecentSearchesDatasource recentSearches,
    CompareSelectionDatasource compareSelection,
    FavoritesDatasource favorites, {
    CommonsLogoCacheDatasource? commonsLogoCache,
    GroupOptionsCacheDatasource? groupOptionsCache,
    Directory? filesRoot,
    NetworkSignals? networkSignals,
    Dio? probeDio,
    Dio? photoDio,
    Future<void> Function()? closeStorage,
  }) {
    final signals = networkSignals ?? NetworkSignals();
    final connectivityCubit = ConnectivityCubit(
      signals: signals,
      probe: DioConnectionProbe(
        dio: probeDio ?? fuelEconomyDio,
        url: ApiConfig.fuelEconomyBaseUrl,
        timeout: const Duration(
          seconds: ConnectivityConfig.probeTimeoutSeconds,
        ),
      ),
      judge: ConnectionJudge(
        slowFailuresToGoOffline: ConnectivityConfig.slowFailuresToGoOffline,
      ),
      backoff: const ReconnectBackoff(
        initialDelay: Duration(
          seconds: ConnectivityConfig.probeInitialDelaySeconds,
        ),
        maxDelay: Duration(seconds: ConnectivityConfig.probeMaxDelaySeconds),
        factor: ConnectivityConfig.probeBackoffFactor,
      ),
      restoredNoticeDuration: const Duration(
        milliseconds: ConnectivityConfig.restoredNoticeMilliseconds,
      ),
    );
    // Sin carpeta de archivos (pruebas) no hay logos ni fotos en disco.
    final logoFileStore = filesRoot == null
        ? null
        : FileLogoFileStore(
            directory: Directory(
              '${filesRoot.path}/${LogoDiskConfig.directoryName}',
            ),
            maxFileBytes: LogoDiskConfig.maxFileBytes,
            maxTotalBytes: LogoDiskConfig.maxTotalBytes,
          );
    final favoritePhotoStore = filesRoot == null
        ? null
        : FileFavoritePhotoStore(
            directory: Directory(
              '${filesRoot.path}/${FavoritesConfig.photosDirectoryName}',
            ),
            dio: photoDio ?? commonsDio,
            maxBytes: FavoritesConfig.photoMaxBytes,
            timeout: const Duration(
              seconds: FavoritesConfig.photoDownloadTimeoutSeconds,
            ),
            downloadUrlOf: (url) => const ThumbnailUrlBuilder().forUrl(
              url,
              FavoritesConfig.photoWidthPixels,
            ),
          );
    final repository = CatalogRepositoryImpl(
      FuelEconomyCatalogDatasource(fuelEconomyDio),
    );
    const sortStrategy = AdaptiveSortStrategy<BrandEntity>(
      smallListStrategy: BubbleSortStrategy<BrandEntity>(),
      largeListStrategy: ShellSortStrategy<BrandEntity>(),
    );
    const groupSortStrategy = AdaptiveSortStrategy<ModelGroupEntity>(
      smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
      largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
    );
    final getAvailableYears = GetAvailableYearsUseCase(repository);
    final commonsQueue = RateLimitedQueue(
      minInterval: const Duration(
        milliseconds: NetworkConfig.commonsMinIntervalMilliseconds,
      ),
      maxRetries: PhotosConfig.maxRetryAttempts,
    );
    final photosRepository = PhotosRepositoryImpl(
      CommonsPhotosDatasource(dio: commonsDio, queue: commonsQueue),
      commonsQueue,
    );
    const photoKeyBuilder = PhotoKeyBuilder(selector: PhotoCandidateSelector());
    final getModelPhoto = GetModelPhotoUseCase(
      repository: photosRepository,
      selector: const PhotoCandidateSelector(),
    );
    final getModelGallery = GetModelGalleryUseCase(
      repository: photosRepository,
      selector: const PhotoCandidateSelector(),
    );
    final fuelEconomyQueue = ConcurrencyLimitedQueue(
      maxConcurrent: NetworkConfig.maxConcurrentRequests,
    );
    final vehicleSpecsRepository = VehicleSpecsRepositoryImpl(
      datasource: FuelEconomyVehicleSpecsDatasource(
        dio: fuelEconomyDio,
        queue: fuelEconomyQueue,
      ),
      queue: fuelEconomyQueue,
    );
    final getGroupSummary = GetGroupSummaryUseCase(vehicleSpecsRepository);
    final getGroupOptions = GetGroupOptionsUseCase(
      vehicleSpecsRepository,
      cache: groupOptionsCache,
    );
    final resolveVehicleDetail = ResolveVehicleDetailUseCase(
      cache: detailCache,
      repository: vehicleSpecsRepository,
      keyBuilder: const VehicleDetailKeyBuilder(),
      clock: DateTime.now,
    );
    // Una sola cola para las dos APIs de NHTSA.
    final nhtsaQueue = ConcurrencyLimitedQueue(
      maxConcurrent: SafetyConfig.maxConcurrentRequests,
    );
    final resolveGroupSafety = ResolveGroupSafetyUseCase(
      cache: safetyCache,
      ratingsRepository: SafetyRatingsRepositoryImpl(
        datasource: NhtsaApiSafetyRatingsDatasource(
          dio: nhtsaApiDio,
          queue: nhtsaQueue,
        ),
      ),
      recallsRepository: RecallsRepositoryImpl(
        NhtsaApiRecallsDatasource(
          apiDio: nhtsaApiDio,
          vpicDio: nhtsaVpicDio,
          queue: nhtsaQueue,
        ),
      ),
      keyBuilder: const SafetyKeyBuilder(),
      clock: DateTime.now,
    );
    final conueeQueue = ConcurrencyLimitedQueue(
      maxConcurrent: ConueeConfig.maxConcurrentRequests,
    );
    final mexicoCatalogRepository = MexicoCatalogRepositoryImpl(
      datasource: ConueeApiDatasource(dio: conueeDio, queue: conueeQueue),
      cache: mexicoCatalogCache,
      clock: DateTime.now,
    );
    final getMxModelGroups = GetMxModelGroupsUseCase(
      repository: mexicoCatalogRepository,
      grouper: const MxModelGrouper(),
    );
    final marketCubit = MarketCubit(preference: marketPreference);
    Market currentMarket() => marketCubit.market;
    final getMxVersions = GetMxVersionsUseCase(getMxModelGroups);
    final resolveGroupSummary = ResolveGroupSummaryUseCase(
      cache: summaryCache,
      getGroupSummary: getGroupSummary,
      keyBuilder: const SummaryKeyBuilder(),
      clock: DateTime.now,
    );
    const transmissionLabeler = TransmissionLabeler(
      onUntranslated: _logUntranslatedText,
    );
    const defaultVersionSelector = DefaultVersionSelector();
    const postingSortStrategy = AdaptiveSortStrategy<SearchPosting>(
      smallListStrategy: BubbleSortStrategy<SearchPosting>(),
      largeListStrategy: ShellSortStrategy<SearchPosting>(),
    );
    const rankedSortStrategy = AdaptiveSortStrategy<RankedSearchEntry>(
      smallListStrategy: BubbleSortStrategy<RankedSearchEntry>(),
      largeListStrategy: ShellSortStrategy<RankedSearchEntry>(),
    );
    const brandNameSortStrategy = AdaptiveSortStrategy<String>(
      smallListStrategy: BubbleSortStrategy<String>(),
      largeListStrategy: ShellSortStrategy<String>(),
    );
    const suggestionSortStrategy = AdaptiveSortStrategy<SuggestionCandidate>(
      smallListStrategy: BubbleSortStrategy<SuggestionCandidate>(),
      largeListStrategy: ShellSortStrategy<SuggestionCandidate>(),
    );
    const yearSortStrategy = AdaptiveSortStrategy<int>(
      smallListStrategy: BubbleSortStrategy<int>(),
      largeListStrategy: ShellSortStrategy<int>(),
    );
    final marketResolveGroupSummary = MarketResolveGroupSummaryUseCase(
      unitedStates: resolveGroupSummary,
      getMxVersions: getMxVersions,
      summaryBuilder: const MxGroupSummaryBuilder(),
      currentMarket: currentMarket,
    );
    final marketLoadGroupDetails = MarketLoadGroupDetailsUseCase(
      unitedStates: LoadGroupDetailsUseCase(
        getGroupOptions: getGroupOptions,
        resolveVehicleDetail: resolveVehicleDetail,
        defaultVersionSelector: defaultVersionSelector,
      ),
      getMxVersions: getMxVersions,
      detailBuilder: const MxVehicleDetailBuilder(),
      labelDisambiguator: const MxVersionLabelDisambiguator(),
    );
    final marketGetModelGroups = MarketGetModelGroupsUseCase(
      unitedStates: GetModelGroupsUseCase(
        repository: repository,
        grouper: const ModelGrouper(sortStrategy: groupSortStrategy),
      ),
      getMxModelGroups: getMxModelGroups,
      currentMarket: currentMarket,
    );
    // Mismas cachés que Detalle: el comparador no repite peticiones.
    final compareLoader = CompareGroupDetailsLoader(
      getModelGroups: marketGetModelGroups,
      loadGroupDetails: marketLoadGroupDetails,
      currentMarket: currentMarket,
    );
    const compareVersionNamer = CompareVersionNamer(
      VersionDescriptorBuilder(transmissionLabeler: transmissionLabeler),
    );
    final searchStore = SearchIndexStore();
    final searchSource = MarketSearchCatalogSource(
      unitedStatesBrands: GetBrandsUseCase(
        repository: repository,
        sortStrategy: sortStrategy,
      ),
      unitedStatesGroups: GetModelGroupsUseCase(
        repository: repository,
        grouper: const ModelGrouper(sortStrategy: groupSortStrategy),
      ),
      mexicoBrands: GetMxBrandsUseCase(mexicoCatalogRepository),
      mexicoGroups: getMxModelGroups,
    );
    final resolveModelPhoto = ResolveModelPhotoUseCase(
      cache: photoCache,
      getModelPhoto: getModelPhoto,
      keyBuilder: photoKeyBuilder,
      clock: DateTime.now,
    );
    const classTranslator = VehicleClassTranslator(
      onUntranslated: _logUntranslatedClass,
    );
    const favoriteClock = DateTime.now;
    return AppDependencies._(
      marketCubit: marketCubit,
      networkSignals: signals,
      connectivityCubit: connectivityCubit,
      logoFileStore: logoFileStore,
      favoritePhotoStore: favoritePhotoStore,
      attachFavoritePhotoUseCase: favoritePhotoStore == null
          ? null
          : AttachFavoritePhotoUseCase(
              datasource: favorites,
              store: favoritePhotoStore,
            ),
      measureFavoritePhotoUseCase: favoritePhotoStore == null
          ? null
          : MeasureFavoritePhotoUseCase(
              datasource: favorites,
              store: favoritePhotoStore,
            ),
      deleteFavoritePhotoUseCase: favoritePhotoStore == null
          ? null
          : DeleteFavoritePhotoUseCase(favoritePhotoStore),
      cleanOrphanFavoritePhotosUseCase: favoritePhotoStore == null
          ? null
          : CleanOrphanFavoritePhotosUseCase(
              datasource: favorites,
              store: favoritePhotoStore,
              clock: DateTime.now,
              grace: const Duration(
                minutes: FavoritesConfig.orphanGraceMinutes,
              ),
            ),
      summaryKeyBuilder: MarketSummaryKeyBuilder(currentMarket),
      catalogRepository: repository,
      getAvailableYearsUseCase: MarketGetAvailableYearsUseCase(
        repository: repository,
        unitedStates: getAvailableYears,
        getMxYears: GetMxYearsUseCase(mexicoCatalogRepository),
        currentMarket: currentMarket,
      ),
      getBrandsUseCase: MarketGetBrandsUseCase(
        unitedStates: GetBrandsUseCase(
          repository: repository,
          sortStrategy: sortStrategy,
        ),
        getMxBrands: GetMxBrandsUseCase(mexicoCatalogRepository),
        currentMarket: currentMarket,
      ),
      getModelGroupsUseCase: marketGetModelGroups,
      brandLogosRepository: BrandLogosRepositoryImpl(
        BrandLogosCdnDatasource(logosDio),
        store: logoFileStore,
      ),
      // Sin caché no hay logos de respaldo: solo se piden con la caché lista.
      resolveCommonsLogoUseCase: commonsLogoCache == null
          ? null
          : ResolveCommonsLogoUseCase(
              cache: commonsLogoCache,
              datasource: CommonsLogoDatasourceImpl(
                dio: commonsDio,
                queue: commonsQueue,
              ),
              selector: const CommonsLogoSelector(),
              clock: DateTime.now,
            ),
      getModelPhotoUseCase: getModelPhoto,
      resolveModelPhotoUseCase: resolveModelPhoto,
      getModelGalleryUseCase: getModelGallery,
      resolveModelGalleryUseCase: ResolveModelGalleryUseCase(
        cache: galleryCache,
        getGallery: getModelGallery,
        keyBuilder: photoKeyBuilder,
        clock: DateTime.now,
      ),
      cancelPendingPhotosUseCase: CancelPendingPhotosUseCase(photosRepository),
      photoKeyBuilder: photoKeyBuilder,
      getGroupSummaryUseCase: getGroupSummary,
      resolveGroupSummaryUseCase: marketResolveGroupSummary,
      cancelPendingSummariesUseCase: CancelPendingSummariesUseCase(
        vehicleSpecsRepository,
      ),
      getGroupOptionsUseCase: getGroupOptions,
      resolveVehicleDetailUseCase: resolveVehicleDetail,
      vehicleClassTranslator: classTranslator,
      driveLabeler: const DriveLabeler(onUntranslated: _logUntranslatedText),
      fuelTypeLabeler: const FuelTypeLabeler(
        onUntranslated: _logUntranslatedText,
      ),
      transmissionLabeler: transmissionLabeler,
      versionDescriptorBuilder: const VersionDescriptorBuilder(
        transmissionLabeler: transmissionLabeler,
      ),
      defaultVersionSelector: defaultVersionSelector,
      loadGroupDetailsUseCase: marketLoadGroupDetails,
      resolveGroupSafetyUseCase: resolveGroupSafety,
      getMxYearsUseCase: GetMxYearsUseCase(mexicoCatalogRepository),
      getMxBrandsUseCase: GetMxBrandsUseCase(mexicoCatalogRepository),
      getMxModelGroupsUseCase: getMxModelGroups,
      getMxVersionsUseCase: getMxVersions,
      buildSearchIndexUseCase: BuildSearchIndexUseCase(
        source: searchSource,
        store: searchStore,
        sortStrategy: postingSortStrategy,
      ),
      searchWithScopeUseCase: SearchWithScopeUseCase(
        store: searchStore,
        ranker: const SearchResultRanker(sortStrategy: rankedSortStrategy),
      ),
      suggestSearchTermsUseCase: SuggestSearchTermsUseCase(
        store: searchStore,
        sortStrategy: suggestionSortStrategy,
      ),
      searchOtherYearsUseCase: SearchOtherYearsUseCase(
        // Instancia propia: construir otros años no interrumpe el índice vigente.
        buildIndex: BuildSearchIndexUseCase(
          source: searchSource,
          store: searchStore,
          sortStrategy: postingSortStrategy,
        ),
        searchCatalog: SearchCatalogUseCase(
          store: searchStore,
          ranker: const SearchResultRanker(sortStrategy: rankedSortStrategy),
        ),
        selector: const NearestYearsSelector(sortStrategy: yearSortStrategy),
      ),
      getBrandGroupsUseCase: GetBrandGroupsUseCase(
        store: searchStore,
        ranker: const SearchResultRanker(sortStrategy: rankedSortStrategy),
      ),
      getIndexBrandsUseCase: GetIndexBrandsUseCase(
        store: searchStore,
        sortStrategy: brandNameSortStrategy,
      ),
      addRecentSearchUseCase: AddRecentSearchUseCase(
        datasource: recentSearches,
        clock: DateTime.now,
      ),
      getRecentSearchesUseCase: GetRecentSearchesUseCase(recentSearches),
      removeRecentSearchUseCase: RemoveRecentSearchUseCase(recentSearches),
      clearRecentSearchesUseCase: ClearRecentSearchesUseCase(recentSearches),
      // Cubit de búsqueda propio (selector del comparador): mismo índice y cachés.
      createIsolatedSearchCubit: (contextSource) {
        BuildSearchIndexUseCase newBuildIndex() => BuildSearchIndexUseCase(
          source: searchSource,
          store: searchStore,
          sortStrategy: postingSortStrategy,
        );
        const ranker = SearchResultRanker(sortStrategy: rankedSortStrategy);
        return SearchCubit(
          contextSource: contextSource,
          buildIndex: newBuildIndex(),
          searchWithScope: SearchWithScopeUseCase(
            store: searchStore,
            ranker: ranker,
          ),
          suggestTerms: SuggestSearchTermsUseCase(
            store: searchStore,
            sortStrategy: suggestionSortStrategy,
          ),
          searchOtherYears: SearchOtherYearsUseCase(
            buildIndex: newBuildIndex(),
            searchCatalog: SearchCatalogUseCase(
              store: searchStore,
              ranker: ranker,
            ),
            selector: const NearestYearsSelector(
              sortStrategy: yearSortStrategy,
            ),
          ),
          getBrandGroups: GetBrandGroupsUseCase(
            store: searchStore,
            ranker: ranker,
          ),
          getIndexBrands: GetIndexBrandsUseCase(
            store: searchStore,
            sortStrategy: brandNameSortStrategy,
          ),
          addRecent: AddRecentSearchUseCase(
            datasource: recentSearches,
            clock: DateTime.now,
          ),
          getRecents: GetRecentSearchesUseCase(recentSearches),
          removeRecent: RemoveRecentSearchUseCase(recentSearches),
          clearRecents: ClearRecentSearchesUseCase(recentSearches),
          analysisRunner: SearchAnalysisRunner(
            source: MarketSearchTraitsSource(marketResolveGroupSummary),
          ),
          filterService: const SearchFilterService(
            sortStrategy: AdaptiveSortStrategy<SearchResultEntity>(
              smallListStrategy: BubbleSortStrategy<SearchResultEntity>(),
              largeListStrategy: ShellSortStrategy<SearchResultEntity>(),
            ),
          ),
        );
      },
      addToCompareUseCase: AddToCompareUseCase(compareSelection),
      removeFromCompareUseCase: RemoveFromCompareUseCase(compareSelection),
      clearCompareUseCase: ClearCompareUseCase(compareSelection),
      observeCompareSelectionUseCase: ObserveCompareSelectionUseCase(
        compareSelection,
      ),
      updateCompareSlotVersionUseCase: UpdateCompareSlotVersionUseCase(
        compareSelection,
      ),
      replaceCompareSlotUseCase: ReplaceCompareSlotUseCase(compareSelection),
      compareVehicleSource: MarketCompareVehicleSource(
        loader: compareLoader,
        versionNamer: compareVersionNamer,
        classTranslator: const VehicleClassTranslator(
          onUntranslated: _logUntranslatedClass,
        ),
        fuelTypeLabeler: const FuelTypeLabeler(
          onUntranslated: _logUntranslatedText,
        ),
        driveLabeler: const DriveLabeler(onUntranslated: _logUntranslatedText),
        transmissionLabeler: transmissionLabeler,
      ),
      compareSafetySource: MarketCompareSafetySource(resolveGroupSafety),
      observeFavoritesUseCase: ObserveFavoritesUseCase(favorites),
      getFavoritesUseCase: GetFavoritesUseCase(favorites),
      toggleFavoriteUseCase: ToggleFavoriteUseCase(
        favorites,
        clock: favoriteClock,
      ),
      removeFavoriteUseCase: RemoveFavoriteUseCase(favorites),
      restoreFavoriteUseCase: RestoreFavoriteUseCase(favorites),
      completeFavoriteSnapshotUseCase: CompleteFavoriteSnapshotUseCase(
        favorites,
      ),
      favoriteSnapshotSource: MarketFavoriteSnapshotSource(
        getModelGroups: marketGetModelGroups,
        resolveGroupSummary: marketResolveGroupSummary,
        resolveModelPhoto: resolveModelPhoto,
        classTranslator: classTranslator,
        currentMarket: currentMarket,
        loadGroupDetails: marketLoadGroupDetails,
      ),
      compareVersionLabeler: MarketCompareVersionLabeler(
        loader: compareLoader,
        namer: compareVersionNamer,
      ),
      compareVersionsSource: MarketCompareVersionsSource(
        loader: compareLoader,
        versionNamer: compareVersionNamer,
      ),
      commonsQueue: commonsQueue,
      fuelEconomyQueue: fuelEconomyQueue,
      nhtsaQueue: nhtsaQueue,
      conueeQueue: conueeQueue,
      closeStorage: closeStorage ?? _noStorageToClose,
    );
  }

  final MarketCubit marketCubit;

  /// Señales de conexión de las peticiones y el cubit que las interpreta.
  final NetworkSignals networkSignals;
  final ConnectivityCubit connectivityCubit;

  /// Disco de logos y de fotos de favoritos; nulos si no hay carpeta de archivos.
  final LogoFileStore? logoFileStore;
  final FavoritePhotoStore? favoritePhotoStore;
  final AttachFavoritePhotoUseCase? attachFavoritePhotoUseCase;
  final MeasureFavoritePhotoUseCase? measureFavoritePhotoUseCase;
  final DeleteFavoritePhotoUseCase? deleteFavoritePhotoUseCase;
  final CleanOrphanFavoritePhotosUseCase? cleanOrphanFavoritePhotosUseCase;
  final SummaryKeyBuilder summaryKeyBuilder;
  final CatalogRepository catalogRepository;
  final GetAvailableYearsUseCase getAvailableYearsUseCase;
  final GetBrandsUseCase getBrandsUseCase;
  final GetModelGroupsUseCase getModelGroupsUseCase;
  final BrandLogosRepository brandLogosRepository;
  final ResolveCommonsLogoUseCase? resolveCommonsLogoUseCase;
  final GetModelPhotoUseCase getModelPhotoUseCase;
  final ResolveModelPhotoUseCase resolveModelPhotoUseCase;
  final GetModelGalleryUseCase getModelGalleryUseCase;
  final ResolveModelGalleryUseCase resolveModelGalleryUseCase;
  final CancelPendingPhotosUseCase cancelPendingPhotosUseCase;
  final PhotoKeyBuilder photoKeyBuilder;
  final GetGroupSummaryUseCase getGroupSummaryUseCase;
  final ResolveGroupSummaryUseCase resolveGroupSummaryUseCase;
  final CancelPendingSummariesUseCase cancelPendingSummariesUseCase;
  final GetGroupOptionsUseCase getGroupOptionsUseCase;
  final ResolveVehicleDetailUseCase resolveVehicleDetailUseCase;
  final VehicleClassTranslator vehicleClassTranslator;
  final DriveLabeler driveLabeler;
  final FuelTypeLabeler fuelTypeLabeler;
  final TransmissionLabeler transmissionLabeler;
  final VersionDescriptorBuilder versionDescriptorBuilder;
  final DefaultVersionSelector defaultVersionSelector;
  final LoadGroupDetailsUseCase loadGroupDetailsUseCase;
  final ResolveGroupSafetyUseCase resolveGroupSafetyUseCase;
  final GetMxYearsUseCase getMxYearsUseCase;
  final GetMxBrandsUseCase getMxBrandsUseCase;
  final GetMxModelGroupsUseCase getMxModelGroupsUseCase;
  final GetMxVersionsUseCase getMxVersionsUseCase;
  final BuildSearchIndexUseCase buildSearchIndexUseCase;
  final SearchWithScopeUseCase searchWithScopeUseCase;
  final SuggestSearchTermsUseCase suggestSearchTermsUseCase;
  final SearchOtherYearsUseCase searchOtherYearsUseCase;
  final GetBrandGroupsUseCase getBrandGroupsUseCase;
  final GetIndexBrandsUseCase getIndexBrandsUseCase;
  final AddRecentSearchUseCase addRecentSearchUseCase;
  final GetRecentSearchesUseCase getRecentSearchesUseCase;
  final RemoveRecentSearchUseCase removeRecentSearchUseCase;
  final ClearRecentSearchesUseCase clearRecentSearchesUseCase;
  final SearchCubit Function(SearchContextSource contextSource)
  createIsolatedSearchCubit;
  final AddToCompareUseCase addToCompareUseCase;
  final RemoveFromCompareUseCase removeFromCompareUseCase;
  final ClearCompareUseCase clearCompareUseCase;
  final ObserveCompareSelectionUseCase observeCompareSelectionUseCase;
  final UpdateCompareSlotVersionUseCase updateCompareSlotVersionUseCase;
  final ReplaceCompareSlotUseCase replaceCompareSlotUseCase;
  final CompareVehicleSource compareVehicleSource;
  final CompareSafetySource compareSafetySource;
  final CompareVersionsSource compareVersionsSource;
  final CompareVersionLabeler compareVersionLabeler;
  final ObserveFavoritesUseCase observeFavoritesUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final RestoreFavoriteUseCase restoreFavoriteUseCase;
  final CompleteFavoriteSnapshotUseCase completeFavoriteSnapshotUseCase;
  final FavoriteSnapshotSource favoriteSnapshotSource;
  final RateLimitedQueue commonsQueue;
  final ConcurrencyLimitedQueue fuelEconomyQueue;
  final ConcurrencyLimitedQueue nhtsaQueue;
  final ConcurrencyLimitedQueue conueeQueue;
  final Future<void> Function() closeStorage;

  static Future<void> _noStorageToClose() async {}

  // Solo en depuración: avisa de una clase de vehículo sin traducción.
  static void _logUntranslatedClass(String originalClass) {
    if (kDebugMode) {
      debugPrint(
        '${VehicleSpecsConfig.untranslatedClassLogPrefix}$originalClass',
      );
    }
  }

  // Solo en depuración: avisa de una tracción, combustible o transmisión sin traducción.
  static void _logUntranslatedText(String original) {
    if (kDebugMode) {
      debugPrint('${VehicleSpecsConfig.untranslatedTextLogPrefix}$original');
    }
  }

  /// Libera los recursos de la composición.
  Future<void> close() async {
    buildSearchIndexUseCase.cancel();
    searchOtherYearsUseCase.cancel();
    await commonsQueue.close();
    await fuelEconomyQueue.close();
    await nhtsaQueue.close();
    await conueeQueue.close();
    await marketCubit.close();
    await connectivityCubit.close();
    await networkSignals.close();
    await closeStorage();
  }
}
