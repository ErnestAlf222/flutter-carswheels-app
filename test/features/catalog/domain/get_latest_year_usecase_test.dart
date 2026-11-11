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

void main() {
  test('devuelve el año más alto de una lista desordenada', () async {
    final useCase = GetLatestYearUseCase(
      _FakeCatalogRepository([2019, 2027, 1985, 2026]),
    );
    expect(await useCase(), 2027);
  });

  test('con un solo año lo devuelve', () async {
    final useCase = GetLatestYearUseCase(_FakeCatalogRepository([2001]));
    expect(await useCase(), 2001);
  });

  test('availableYears devuelve los años descendentes sin repetir', () async {
    final useCase = GetLatestYearUseCase(
      _FakeCatalogRepository([2019, 2027, 2019, 2026]),
    );
    expect(await useCase.availableYears(), [2027, 2026, 2019]);
  });

  test('con lista vacía lanza ParsingFailure', () async {
    final useCase = GetLatestYearUseCase(_FakeCatalogRepository([]));
    await expectLater(useCase(), throwsA(isA<ParsingFailure>()));
  });
}
