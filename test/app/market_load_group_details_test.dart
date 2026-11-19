import 'package:cars_wheels_app/app/market_catalog/market_load_group_details_usecase.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/conuee_test_support.dart';
import '../support/detail_test_support.dart';

class _MockOptions extends Mock implements GetGroupOptionsUseCase {}

class _MockResolve extends Mock implements ResolveVehicleDetailUseCase {}

/// Caso de EE. UU. que anota si lo llamaron.
class _UsLoad extends LoadGroupDetailsUseCase {
  _UsLoad()
    : super(
        getGroupOptions: _MockOptions(),
        resolveVehicleDetail: _MockResolve(),
        defaultVersionSelector: const DefaultVersionSelector(),
      );

  int calls = 0;

  @override
  Future<GroupDetailsEntity> call(DetailArgsEntity args) async {
    calls++;
    return const GroupDetailsEntity(versions: [], defaultIndex: 0);
  }
}

class _CountingMxRepository implements MexicoCatalogRepository {
  _CountingMxRepository(this.vehicles);

  final List<MxVehicleEntity> vehicles;
  int yearCalls = 0;

  @override
  Future<List<int>> fetchYears() async => [2025];

  @override
  Future<MxYearCatalogEntity> fetchYear(int year) async {
    yearCalls++;
    return mxCatalog(year, vehicles);
  }
}

void main() {
  late _UsLoad us;

  MarketLoadGroupDetailsUseCase build(List<MxVehicleEntity> vehicles) {
    us = _UsLoad();
    return MarketLoadGroupDetailsUseCase(
      unitedStates: us,
      getMxVersions: GetMxVersionsUseCase(
        GetMxModelGroupsUseCase(
          repository: _CountingMxRepository(vehicles),
          grouper: const MxModelGrouper(),
        ),
      ),
      detailBuilder: const MxVehicleDetailBuilder(),
      labelDisambiguator: const MxVersionLabelDisambiguator(),
    );
  }

  DetailArgsEntity args(String brand, String group, Market market) =>
      DetailArgsEntity(
        brand: brand,
        groupName: group,
        year: 2025,
        variantNames: const [],
        photo: null,
        heroTag: 'h',
        market: market,
      );

  test('con mercado EE. UU. delega en el caso de EE. UU.', () async {
    final useCase = build([conueeVehicle('COROLLA')]);
    await useCase(args('Toyota', 'COROLLA', Market.unitedStates));
    expect(us.calls, 1);
  });

  test(
    'con mercado México arma las versiones del catálogo sin EE. UU.',
    () async {
      final useCase = build([
        conueeVehicle('COROLLA'),
        conueeVehicle('COROLLA HIBRIDO'),
      ]);
      final details = await useCase(args('Toyota', 'COROLLA', Market.mexico));
      expect(us.calls, 0);
      expect(details.versions, hasLength(2));
      expect(details.versions.map((v) => v.label), [
        'COROLLA',
        'COROLLA HIBRIDO',
      ]);
      expect(details.versions.first.detail.year, 2025);
    },
  );

  test('la versión por defecto es la de consumo mediano', () async {
    MxVehicleEntity row(int id, double km, String transmission) =>
        MxVehicleEntity(
          id: id,
          brand: 'Marca',
          rawModel: 'MODELO',
          model: 'MODELO',
          engineKind: EngineKind.gasoline,
          combinedKmPerLiter: km,
          transmission: transmission,
        );
    final useCase = build([
      row(0, 19.1, 'Manual'),
      row(1, 31.3, 'CVT'),
      row(2, 25.9, 'Automática'),
    ]);
    final details = await useCase(args('Marca', 'MODELO', Market.mexico));
    // 19.1, 25.9 y 31.3 km/l: la mediana es la de 25.9.
    expect(
      details.versions[details.defaultIndex].detail.combinedKmPerLiter,
      25.9,
    );
    expect(details.versions[details.defaultIndex].label, 'MODELO · Automática');
  });

  test('sin ningún km/l la versión por defecto es la primera', () async {
    final useCase = build([
      conueeVehicle('OUTLANDER PHEV SE PLUS'),
      conueeVehicle('LYRIQ F'),
    ]);
    final details = await useCase(
      args('Mitsubishi', 'OUTLANDER PHEV SE PLUS', Market.mexico),
    );
    expect(details.defaultIndex, 0);
  });

  test('un grupo que no existe da una lista vacía', () async {
    final useCase = build([conueeVehicle('COROLLA')]);
    final details = await useCase(args('Toyota', 'NADA', Market.mexico));
    expect(details.versions, isEmpty);
  });

  test('con el catálogo ya cargado no pide otra vez al año de la red', () async {
    final repository = _CountingMxRepository([conueeVehicle('COROLLA')]);
    final useCase = MarketLoadGroupDetailsUseCase(
      unitedStates: _UsLoad(),
      getMxVersions: GetMxVersionsUseCase(
        GetMxModelGroupsUseCase(
          repository: repository,
          grouper: const MxModelGrouper(),
        ),
      ),
      detailBuilder: const MxVehicleDetailBuilder(),
      labelDisambiguator: const MxVersionLabelDisambiguator(),
    );
    await useCase(args('Toyota', 'COROLLA', Market.mexico));
    // Una sola lectura del catálogo del año (memoria o caché del repositorio).
    expect(repository.yearCalls, 1);
  });

  test('DetailArgsEntity usa EE. UU. por defecto', () {
    expect(testArgs().market, Market.unitedStates);
  });
}
