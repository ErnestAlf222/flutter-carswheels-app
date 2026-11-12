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

GetModelGroupsUseCase _useCase(_FakeCatalogRepository repository) =>
    GetModelGroupsUseCase(
      repository: repository,
      grouper: const ModelGrouper(
        sortStrategy: AdaptiveSortStrategy<ModelGroupEntity>(
          smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
          largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
        ),
      ),
    );

void main() {
  test('pide al repositorio el año y la marca dados', () async {
    final repository = _FakeCatalogRepository(const []);
    await _useCase(repository)(2027, 'Aston Martin');
    expect(repository.requestedYear, 2027);
    expect(repository.requestedBrand, 'Aston Martin');
  });

  test('devuelve los modelos agrupados y ordenados', () async {
    final repository = _FakeCatalogRepository(const [
      ModelEntity(name: 'Fit'),
      ModelEntity(name: 'Civic 4Dr'),
      ModelEntity(name: 'Civic'),
    ]);
    final groups = await _useCase(repository)(2020, 'Honda');
    expect(groups.map((g) => g.name), ['Civic', 'Fit']);
    expect(groups.first.variants.length, 2);
  });

  test('con lista vacía devuelve vacía', () async {
    final repository = _FakeCatalogRepository(const []);
    expect(await _useCase(repository)(2020, 'Honda'), isEmpty);
  });
}
