import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogDatasource implements CatalogDatasource {
  int? requestedYear;
  String? requestedBrand;

  @override
  Future<List<int>> fetchYears() async => [2026, 2025];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async {
    requestedYear = year;
    return const [BrandEntity(name: 'Audi')];
  }

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async {
    requestedYear = year;
    requestedBrand = brand;
    return const [ModelEntity(name: 'A4')];
  }
}

void main() {
  test('fetchYears delega en el datasource', () async {
    final repository = CatalogRepositoryImpl(_FakeCatalogDatasource());
    expect(await repository.fetchYears(), [2026, 2025]);
  });

  test('fetchBrands delega en el datasource con el mismo año', () async {
    final datasource = _FakeCatalogDatasource();
    final repository = CatalogRepositoryImpl(datasource);
    expect(await repository.fetchBrands(2024), const [
      BrandEntity(name: 'Audi'),
    ]);
    expect(datasource.requestedYear, 2024);
  });

  test('fetchModels delega en el datasource con año y marca', () async {
    final datasource = _FakeCatalogDatasource();
    final repository = CatalogRepositoryImpl(datasource);
    expect(await repository.fetchModels(2024, 'Audi'), const [
      ModelEntity(name: 'A4'),
    ]);
    expect(datasource.requestedYear, 2024);
    expect(datasource.requestedBrand, 'Audi');
  });
}
