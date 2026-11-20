import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/infrastructure/mappers/compare_payload_mapper.dart';
import 'package:cars_wheels_app/features/compare/infrastructure/models/compare_selection_model.dart';

/// Selección del comparador guardada en Isar, una fila por mercado.
class IsarCompareSelectionDatasource implements CompareSelectionDatasource {
  const IsarCompareSelectionDatasource(this.isar, {required this.clock});

  final Isar isar;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  @override
  Future<List<CompareSlotEntity>> read(String marketCode) async {
    final model = await isar.compareSelectionModels.getByKey(
      ComparePayloadMapper.keyFor(marketCode),
    );
    if (model == null) return const [];
    try {
      return ComparePayloadMapper.fromPayload(model.payload);
    } on Object {
      // Un payload ilegible cuenta como selección vacía.
      return const [];
    }
  }

  @override
  Future<void> write(String marketCode, List<CompareSlotEntity> slots) {
    final model = CompareSelectionModel(
      key: ComparePayloadMapper.keyFor(marketCode),
      payload: ComparePayloadMapper.toPayload(slots),
      savedAtMillis: clock().millisecondsSinceEpoch,
    );
    return isar.writeTxn(() => isar.compareSelectionModels.putByKey(model));
  }

  @override
  Stream<List<CompareSlotEntity>> watch(String marketCode) => isar
      .compareSelectionModels
      .watchLazy(fireImmediately: true)
      .asyncMap((_) => read(marketCode));
}
