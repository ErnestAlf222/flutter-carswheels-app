import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.models);

  final List<ModelEntity> models;
  int? requestedYear;
  String? requestedBrand;

  @override
  Future<List<int>> fetchYears() async => const [];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async {
    requestedYear = year;
    requestedBrand = brand;
    return models;
  }
}

GetModelsUseCase _useCase(
  List<String> names, [
  _FakeCatalogRepository? repository,
]) => GetModelsUseCase(
  repository:
      repository ??
      _FakeCatalogRepository([
        for (final name in names) ModelEntity(name: name),
      ]),
  sortStrategy: const AdaptiveSortStrategy<ModelEntity>(
    smallListStrategy: BubbleSortStrategy<ModelEntity>(),
    largeListStrategy: ShellSortStrategy<ModelEntity>(),
  ),
);

void main() {
  test('ordena sin distinguir mayúsculas ni acentos', () async {
    final result = await _useCase(['bolt', 'Écho', 'Accord', 'acura', 'Fit'])(
      2020,
      'Honda',
    );
    expect(result.map((m) => m.name), [
      'Accord',
      'acura',
      'bolt',
      'Écho',
      'Fit',
    ]);
  });

  test('quita los nombres idénticos', () async {
    final result = await _useCase(['Civic', 'Accord', 'Civic'])(2020, 'Honda');
    expect(result.map((m) => m.name), ['Accord', 'Civic']);
  });

  test('con lista vacía devuelve vacía', () async {
    expect(await _useCase([])(2020, 'Honda'), isEmpty);
  });

  test('no agrupa: Civic 2Dr y Civic 4Dr siguen separados', () async {
    final result = await _useCase(['Civic 4Dr', 'Civic 2Dr'])(2020, 'Honda');
    expect(result.map((m) => m.name), ['Civic 2Dr', 'Civic 4Dr']);
  });

  test('pide al repositorio el año y la marca dados', () async {
    final repository = _FakeCatalogRepository(const []);
    await _useCase(const [], repository)(2027, 'Aston Martin');
    expect(repository.requestedYear, 2027);
    expect(repository.requestedBrand, 'Aston Martin');
  });

  test('ordena correctamente una lista grande', () async {
    final generated = List<String>.generate(
      AlgorithmsConfig.bubbleSortMaxItems * 3,
      (index) => 'Modelo ${(index * 7919) % 1000}',
    );
    final result = await _useCase(generated)(2020, 'Honda');
    final keys = result.map((m) => TextNormalizer.normalize(m.name)).toList();
    expect([...keys]..sort(), keys);
    expect(result.length, generated.toSet().length);
  });
}
