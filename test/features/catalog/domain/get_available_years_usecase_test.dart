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
  test('devuelve los años descendentes sin repetir', () async {
    final useCase = GetAvailableYearsUseCase(
      _FakeCatalogRepository([2019, 2027, 2019, 2026]),
    );
    expect(await useCase(), [2027, 2026, 2019]);
  });

  test('con lista vacía lanza ParsingFailure', () async {
    final useCase = GetAvailableYearsUseCase(_FakeCatalogRepository([]));
    await expectLater(useCase(), throwsA(isA<ParsingFailure>()));
  });
}
