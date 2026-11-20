import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Instantánea de un modelo con los casos de uso y cachés de resumen y foto.
///
/// Cada parte se resuelve por separado: si una falla, las demás se guardan igual
/// y lo que falta queda vacío, nunca inventado.
class MarketFavoriteSnapshotSource implements FavoriteSnapshotSource {
  const MarketFavoriteSnapshotSource({
    required this.getModelGroups,
    required this.resolveGroupSummary,
    required this.resolveModelPhoto,
    required this.classTranslator,
    required this.currentMarket,
  });

  final GetModelGroupsUseCase getModelGroups;
  final ResolveGroupSummaryUseCase resolveGroupSummary;
  final ResolveModelPhotoUseCase resolveModelPhoto;
  final VehicleClassTranslator classTranslator;
  final Market Function() currentMarket;

  @override
  Future<FavoriteSnapshotEntity?> snapshotOf(FavoriteIdentity identity) async {
    final market = Market.fromCode(identity.marketCode);
    // Los casos de uso del catálogo trabajan con el mercado vigente.
    if (market == null || market != currentMarket()) return null;
    final variants = await _variantsOf(identity);
    final summary = await _summaryOf(identity, variants);
    final photo = await _photoOf(identity);
    return FavoriteSnapshotEntity(
      // México trae el combustible ya traducido; EE. UU., la clase a traducir.
      label:
          summary?.fuelLabel ?? classTranslator.labelFor(summary?.vehicleClass),
      engineKinds: [
        for (final kind in summary?.engineKinds ?? const <EngineKind>[])
          kind.name,
      ],
      minKmPerLiter: summary?.minKmPerLiter,
      maxKmPerLiter: summary?.maxKmPerLiter,
      variantNames: variants,
      photo: photo == null
          ? null
          : FavoritePhotoEntity(
              thumbnailUrl: photo.thumbnailUrl,
              authorName: photo.authorName,
              licenseName: photo.licenseName,
              sourceUrl: photo.sourceUrl,
              isReference: photo.isReference,
              aspectRatio: photo.aspectRatio,
            ),
    );
  }

  Future<List<String>> _variantsOf(FavoriteIdentity identity) async {
    try {
      final groups = await getModelGroups(identity.year, identity.brand);
      final group = groups
          .where((candidate) => candidate.name == identity.modelName)
          .firstOrNull;
      return [
        for (final variant in group?.variants ?? const <ModelEntity>[])
          variant.name,
      ];
    } on Object {
      return const [];
    }
  }

  Future<GroupSummaryEntity?> _summaryOf(
    FavoriteIdentity identity,
    List<String> variants,
  ) async {
    try {
      return await resolveGroupSummary(
        year: identity.year,
        brand: identity.brand,
        groupName: identity.modelName,
        variantNames: variants,
      );
    } on Object {
      return null;
    }
  }

  Future<PhotoEntity?> _photoOf(FavoriteIdentity identity) async {
    try {
      return await resolveModelPhoto(
        brand: identity.brand,
        modelName: identity.modelName,
        year: identity.year,
      );
    } on Object {
      return null;
    }
  }
}
