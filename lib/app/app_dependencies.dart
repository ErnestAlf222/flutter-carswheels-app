import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';

/// Construye las dependencias de la app en un solo lugar.
class AppDependencies {
  AppDependencies._({
    required this.catalogRepository,
    required this.getLatestYearUseCase,
    required this.getBrandsUseCase,
    required this.brandLogosRepository,
  });

  factory AppDependencies.create() {
    final fuelEconomyDio = ApiClientFactory.create(
      baseUrl: ApiConfig.fuelEconomyBaseUrl,
      acceptHeaderValue: FuelEconomyConfig.acceptHeaderValue,
      userAgent: UserAgentsConfig.fuelEconomyUserAgent,
    );
    final logosDio = ApiClientFactory.create(
      baseUrl: LogosConfig.logosBaseUrl,
      acceptHeaderValue: LogosConfig.acceptHeaderValue,
      userAgent: UserAgentsConfig.logosUserAgent,
    );
    return AppDependencies.fromDio(fuelEconomyDio, logosDio);
  }

  /// Compone todo sobre un Dio dado.
  factory AppDependencies.fromDio(Dio fuelEconomyDio, Dio logosDio) {
    final repository = CatalogRepositoryImpl(
      FuelEconomyCatalogDatasource(fuelEconomyDio),
    );
    const sortStrategy = AdaptiveSortStrategy<BrandEntity>(
      smallListStrategy: BubbleSortStrategy<BrandEntity>(),
      largeListStrategy: ShellSortStrategy<BrandEntity>(),
    );
    return AppDependencies._(
      catalogRepository: repository,
      getLatestYearUseCase: GetLatestYearUseCase(repository),
      getBrandsUseCase: GetBrandsUseCase(
        repository: repository,
        sortStrategy: sortStrategy,
      ),
      brandLogosRepository: BrandLogosRepositoryImpl(
        BrandLogosCdnDatasource(logosDio),
      ),
    );
  }

  final CatalogRepository catalogRepository;
  final GetLatestYearUseCase getLatestYearUseCase;
  final GetBrandsUseCase getBrandsUseCase;
  final BrandLogosRepository brandLogosRepository;
}
