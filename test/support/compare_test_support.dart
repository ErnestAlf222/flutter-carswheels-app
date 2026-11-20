import 'dart:async';

import 'package:cars_wheels_app/features/compare/compare.dart';

/// Vehículo de prueba: un Corolla 2024 de Toyota en EE. UU. salvo que se cambie.
CompareSlotEntity compareSlot({
  String model = 'Corolla',
  String brand = 'Toyota',
  int year = 2024,
  String marketCode = 'us',
  String? versionKey,
}) => CompareSlotEntity(
  marketCode: marketCode,
  year: year,
  brand: brand,
  groupKey: model.toLowerCase(),
  modelName: model,
  versionKey: versionKey,
);

/// Selección en memoria por mercado, con el mismo contrato que la de Isar.
class InMemoryCompareSelection implements CompareSelectionDatasource {
  final Map<String, List<CompareSlotEntity>> _byMarket = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Cuántas veces se escribió; las pruebas lo usan para ver que nada se guardó.
  int writes = 0;

  @override
  Future<List<CompareSlotEntity>> read(String marketCode) async =>
      List.of(_byMarket[marketCode] ?? const []);

  @override
  Future<void> write(String marketCode, List<CompareSlotEntity> slots) async {
    writes++;
    _byMarket[marketCode] = List.of(slots);
    _changes.add(null);
  }

  @override
  Stream<List<CompareSlotEntity>> watch(String marketCode) {
    late final StreamController<List<CompareSlotEntity>> controller;
    StreamSubscription<void>? subscription;
    controller = StreamController<List<CompareSlotEntity>>(
      onListen: () async {
        controller.add(await read(marketCode));
        subscription = _changes.stream.listen(
          (_) async => controller.add(await read(marketCode)),
        );
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }
}

/// Mercado de prueba que se cambia a mano.
class FakeCompareMarketSource implements CompareMarketSource {
  FakeCompareMarketSource([this.marketCode = 'us']);

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  @override
  String marketCode;

  @override
  Stream<String> get marketChanges => _controller.stream;

  void switchTo(String code) {
    marketCode = code;
    _controller.add(code);
  }
}

/// Cubit de prueba armado sobre una selección en memoria.
CompareCubit buildCompareCubit({
  InMemoryCompareSelection? selection,
  FakeCompareMarketSource? market,
  Duration noticeDuration = const Duration(seconds: 3),
}) {
  final store = selection ?? InMemoryCompareSelection();
  return CompareCubit(
    marketSource: market ?? FakeCompareMarketSource(),
    addToCompare: AddToCompareUseCase(store),
    removeFromCompare: RemoveFromCompareUseCase(store),
    clearCompare: ClearCompareUseCase(store),
    observeSelection: ObserveCompareSelectionUseCase(store),
    updateSlotVersion: UpdateCompareSlotVersionUseCase(store),
    replaceSlot: ReplaceCompareSlotUseCase(store),
    noticeDuration: noticeDuration,
  );
}

/// Fuente de vehículos de prueba: respuestas por modelo, con espera y fallas.
///
/// La respuesta se busca por "modelo|versión" y luego por modelo; sin ninguna
/// devuelve un vehículo vacío.
class FakeCompareVehicleSource implements CompareVehicleSource {
  final Map<String, CompareVehicleDetailEntity?> details = {};

  /// Modelos cuya carga lanza.
  final Set<String> failing = {};

  /// Modelos que esperan a que se complete su compuerta.
  final Map<String, Completer<void>> gates = {};

  /// Identidades pedidas, en orden; sirve para contar peticiones.
  final List<String> requests = [];

  @override
  Future<CompareVehicleDetailEntity?> detailOf(CompareSlotEntity slot) async {
    requests.add(slot.identity);
    final gate = gates[slot.modelName];
    if (gate != null) await gate.future;
    if (failing.contains(slot.modelName)) throw StateError('sin red');
    final key = '${slot.modelName}|${slot.versionKey ?? ''}';
    return details.containsKey(key)
        ? details[key]
        : details[slot.modelName] ?? const CompareVehicleDetailEntity();
  }
}

/// Seguridad de prueba: estrellas por modelo, con fallas.
class FakeCompareSafetySource implements CompareSafetySource {
  final Map<String, int?> stars = {};
  final Set<String> failing = {};

  @override
  Future<int?> overallStarsOf(CompareSlotEntity slot) async {
    if (failing.contains(slot.modelName)) throw StateError('sin red');
    return stars[slot.modelName];
  }
}

/// Versiones de prueba por modelo, con espera y falla.
class FakeCompareVersionsSource implements CompareVersionsSource {
  final Map<String, List<CompareVersionOptionEntity>> versions = {};
  bool failing = false;
  int requests = 0;

  @override
  Future<List<CompareVersionOptionEntity>> versionsOf(
    CompareSlotEntity slot,
  ) async {
    requests++;
    if (failing) throw StateError('sin red');
    return versions[slot.modelName] ?? const [];
  }
}

/// Cubit de la tabla de prueba sobre un cubit de selección ya armado.
CompareTableCubit buildCompareTableCubit({
  required CompareCubit compare,
  required FakeCompareVehicleSource vehicles,
  FakeCompareSafetySource? safety,
}) => CompareTableCubit(
  compare: compare,
  vehicleSource: vehicles,
  safetySource: safety ?? FakeCompareSafetySource(),
);
