import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.brands);

  final List<BrandEntity> brands;

  @override
  Future<List<int>> fetchYears() async => const [];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => brands;

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async =>
      const [];
}

GetBrandsUseCase _useCase(List<String> names) => GetBrandsUseCase(
  repository: _FakeCatalogRepository([
    for (final name in names) BrandEntity(name: name),
  ]),
  sortStrategy: const AdaptiveSortStrategy<BrandEntity>(
    smallListStrategy: BubbleSortStrategy<BrandEntity>(),
    largeListStrategy: ShellSortStrategy<BrandEntity>(),
  ),
);

void main() {
  test('ordena sin distinguir mayúsculas ni acentos', () async {
    final result = await _useCase(['bmw', 'Écrin', 'Audi', 'acura', 'Ford'])(
      2020,
    );
    expect(result.map((b) => b.name), [
      'acura',
      'Audi',
      'bmw',
      'Écrin',
      'Ford',
    ]);
  });

  test('no duplica ni pierde elementos (lista grande)', () async {
    final generated = List<String>.generate(
      AlgorithmsConfig.bubbleSortMaxItems * 3,
      (index) => 'Marca ${(index * 7919) % 1000}',
    );
    final result = await _useCase(generated)(2020);
    expect(result.map((b) => b.name).toList()..sort(), [...generated]..sort());
    final keys = result.map((b) => TextNormalizer.normalize(b.name)).toList();
    expect([...keys]..sort(), keys);
  });

  test('con lista vacía devuelve vacía', () async {
    expect(await _useCase([])(2020), isEmpty);
  });
}
