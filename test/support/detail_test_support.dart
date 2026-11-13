import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import 'brand_logos_test_support.dart';
import 'class_translator_test_support.dart';

/// Desactiva la descarga de fuentes; llamar en setUpAll de cada archivo.
void disableFontFetching() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// Cubit de galería falso para pruebas de widgets.
class MockDetailGalleryCubit extends MockCubit<GalleryState>
    implements DetailGalleryCubit {}

/// Caso de uso de galería falso para pruebas de páginas.
class MockResolveModelGalleryUseCase extends Mock
    implements ResolveModelGalleryUseCase {}

/// Cubit de galería falso con el estado dado.
MockDetailGalleryCubit buildMockGalleryCubit([
  GalleryState state = const GalleryState(),
]) {
  final cubit = MockDetailGalleryCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.selectPage(any())).thenReturn(null);
  return cubit;
}

/// Foto de prueba; la URL no se pide porque las pruebas no tienen red.
PhotoEntity testPhoto({
  String url = 'https://upload.test/civic-960px.jpg',
  String source = 'fuente',
  String author = 'Autora',
  String license = 'CC BY 4.0',
  bool isReference = false,
  double? aspectRatio,
}) => PhotoEntity(
  thumbnailUrl: url,
  authorName: author,
  licenseName: license,
  sourceUrl: source,
  isReference: isReference,
  aspectRatio: aspectRatio,
);

/// Detalle de una versión; solo los campos que cambian entre pruebas.
VehicleDetailEntity testDetail({
  int id = 1,
  String? vehicleClass = 'Compact Cars',
  Powertrain powertrain = Powertrain.combustion,
  String? transmission = 'Automatic (AV-S10)',
  int? cylinders = 4,
  double? displacementLiters = 2.0,
  String? drive = 'Front-Wheel Drive',
  String? fuelType = 'Regular',
  double? combinedKmPerLiter = 14.62,
  int? annualFuelCostUsd = 1750,
  double? cityKmPerLiter,
  double? highwayKmPerLiter,
  double? co2GramsPerKilometer,
  double? electricRangeKilometers,
  double? totalRangeKilometers,
  double? electricConsumptionKwhPer100Kilometers,
  double? hybridGasKmPerLiter,
  int? fuelScore,
  int? emissionsScore,
}) => VehicleDetailEntity(
  id: id,
  year: 2020,
  make: 'Toyota',
  model: 'Corolla',
  vehicleClass: vehicleClass,
  powertrain: powertrain,
  transmission: transmission,
  cylinders: cylinders,
  displacementLiters: displacementLiters,
  drive: drive,
  fuelType: fuelType,
  cityKmPerLiter: cityKmPerLiter,
  highwayKmPerLiter: highwayKmPerLiter,
  combinedKmPerLiter: combinedKmPerLiter,
  annualFuelCostUsd: annualFuelCostUsd,
  co2GramsPerKilometer: co2GramsPerKilometer,
  electricRangeKilometers: electricRangeKilometers,
  totalRangeKilometers: totalRangeKilometers,
  electricConsumptionKwhPer100Kilometers:
      electricConsumptionKwhPer100Kilometers,
  hybridGasKmPerLiter: hybridGasKmPerLiter,
  fuelScore: fuelScore,
  emissionsScore: emissionsScore,
);

/// Versión de un grupo con su variante.
GroupVersionEntity testVersion(
  VehicleDetailEntity detail, {
  String variantName = 'Corolla',
}) => GroupVersionEntity(variantName: variantName, detail: detail);

/// Argumentos de Detalle de prueba.
DetailArgsEntity testArgs({PhotoEntity? photo, String groupName = 'Corolla'}) =>
    DetailArgsEntity(
      brand: 'Toyota',
      groupName: groupName,
      year: 2020,
      variantNames: [groupName],
      photo: photo,
      heroTag: 'hero-tag',
    );

/// Envuelve un widget de Detalle con lo que la app inyecta, dentro de un Scaffold.
Widget detailHost(
  Widget child, {
  double textScale = 1,
  bool disableAnimations = true,
  Map<String, String> logoUrls = const {},
  DetailGalleryCubit? galleryCubit,
  PhotoPrefetcher prefetcher = const PhotoPrefetcher(),
}) => MaterialApp(
  // Los proveedores van sobre el Navigator, como en la app, para que la hoja los vea.
  builder: (context, home) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: disableAnimations,
    ),
    child: withClassTranslator(
      RepositoryProvider<VersionDescriptorBuilder>.value(
        value: const VersionDescriptorBuilder(
          transmissionLabeler: TransmissionLabeler(),
        ),
        child: RepositoryProvider<PhotoPrefetcher>.value(
          value: prefetcher,
          child: BlocProvider<DetailGalleryCubit>.value(
            value: galleryCubit ?? buildMockGalleryCubit(),
            child: BlocProvider<BrandLogosCubit>.value(
              value: buildMockBrandLogosCubit(urls: logoUrls),
              child: home!,
            ),
          ),
        ),
      ),
    ),
  ),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
