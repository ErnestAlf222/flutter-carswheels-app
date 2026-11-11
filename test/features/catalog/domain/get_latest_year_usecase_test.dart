import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.years);

  final List<int> years;

  @override
  Future<List<int>> fetchYears() async => years;

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async =>
      const [];
}

GetLatestYearUseCase _latest(List<int> years) => GetLatestYearUseCase(
  GetAvailableYearsUseCase(_FakeCatalogRepository(years)),
);

void main() {
  test('devuelve el año más alto de una lista desordenada', () async {
    expect(await _latest([2019, 2027, 1985, 2026])(), 2027);
  });

  test('con un solo año lo devuelve', () async {
    expect(await _latest([2001])(), 2001);
  });

  test('con lista vacía lanza ParsingFailure', () async {
    await expectLater(_latest([])(), throwsA(isA<ParsingFailure>()));
  });
}
