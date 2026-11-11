import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogDatasource implements CatalogDatasource {
  int? requestedYear;

  @override
  Future<List<int>> fetchYears() async => [2026, 2025];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async {
    requestedYear = year;
    return const [BrandEntity(name: 'Audi')];
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
}
