import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/entities/detail_args_entity.dart';
import 'package:cars_wheels_app/features/detail/domain/entities/group_details_entity.dart';
import 'package:cars_wheels_app/features/detail/domain/entities/group_version_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

// Resultado de resolver una opción: su versión, o el fallo que lo impidió.
typedef _ResolvedVersion = ({GroupVersionEntity? version, AppFailure? failure});

/// Reúne todas las versiones de un grupo con su detalle.
class LoadGroupDetailsUseCase {
  const LoadGroupDetailsUseCase({
    required this.getGroupOptions,
    required this.resolveVehicleDetail,
    required this.defaultVersionSelector,
  });

  final GetGroupOptionsUseCase getGroupOptions;
  final ResolveVehicleDetailUseCase resolveVehicleDetail;
  final DefaultVersionSelector defaultVersionSelector;

  /// Omite las versiones sin detalle o que fallan; la cancelación se relanza.
  /// Si no queda ninguna y hubo un fallo de red, relanza ese fallo.
  Future<GroupDetailsEntity> call(DetailArgsEntity args) async {
    final options = await getGroupOptions(
      year: args.year,
      brand: args.brand,
      variantNames: args.variantNames,
    );
    // Todas se lanzan a la vez; la cola de la infraestructura limita la concurrencia.
    final resolved = await Future.wait([
      for (final option in options) _resolve(args, option),
    ]);
    final versions = [
      for (final item in resolved)
        if (item.version != null) item.version!,
    ];
    if (versions.isEmpty) {
      final networkFailure = resolved
          .map((item) => item.failure)
          .whereType<NetworkFailure>()
          .firstOrNull;
      if (networkFailure != null) throw networkFailure;
      return const GroupDetailsEntity(versions: [], defaultIndex: 0);
    }
    return GroupDetailsEntity(
      versions: versions,
      defaultIndex: defaultVersionSelector.selectIndex([
        for (final version in versions) version.detail,
      ]),
    );
  }

  // Resuelve una opción; la cancelación se relanza y los demás fallos se guardan.
  Future<_ResolvedVersion> _resolve(
    DetailArgsEntity args,
    GroupOptionEntity option,
  ) async {
    try {
      final detail = await resolveVehicleDetail(
        id: option.option.id,
        year: args.year,
        brand: args.brand,
        model: option.variantName,
      );
      if (detail == null) return (version: null, failure: null);
      return (
        version: GroupVersionEntity(
          variantName: option.variantName,
          detail: detail,
        ),
        failure: null,
      );
    } on CancelledFailure {
      rethrow;
    } on AppFailure catch (failure) {
      return (version: null, failure: failure);
    }
  }
}
