import 'package:flutter_test/flutter_test.dart';

import 'package:cars_wheels_app/app/compare/compare_picks.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/search/search.dart';

import '../support/compare_test_support.dart';

SearchResultEntity _pick(String model, {String brand = 'Toyota'}) =>
    SearchResultEntity(
      brand: brand,
      groupName: model,
      variantNames: const [],
      year: 2024,
      marketCode: 'us',
    );

void main() {
  final picks = [
    for (final model in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'])
      _pick(model),
  ];

  test('muestra como máximo la cantidad de la config', () {
    final shown = picksWithoutCompared(
      picks,
      const CompareLoaded(selection: CompareSelectionEntity.empty),
    );
    expect(shown, hasLength(CompareConfig.suggestionsCount));
  });

  test('excluye los autos ya agregados, con cualquier versión', () {
    final state = CompareLoaded(
      selection: CompareSelectionEntity([
        compareSlot(model: 'A', versionKey: 'v1'),
      ]),
    );
    final shown = picksWithoutCompared(picks, state);
    expect(shown.map((pick) => pick.groupName), isNot(contains('A')));
    expect(shown, hasLength(CompareConfig.suggestionsCount));
  });

  test('otra marca con el mismo nombre no se excluye', () {
    final state = CompareLoaded(
      selection: CompareSelectionEntity([compareSlot(model: 'A')]),
    );
    final shown = picksWithoutCompared([_pick('A', brand: 'Honda')], state);
    expect(shown, hasLength(1));
  });

  test('mientras la selección carga no se excluye nada', () {
    final shown = picksWithoutCompared(picks, const CompareLoading());
    expect(shown, hasLength(CompareConfig.suggestionsCount));
  });
}
