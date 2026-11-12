import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('los sufijos de variante no están vacíos', () {
    expect(ModelGroupingConfig.variantTrailingTokens, isNotEmpty);
    expect(ModelGroupingConfig.variantTrailingTokens, contains('twin motor'));
    for (final token in ModelGroupingConfig.variantTrailingTokens) {
      expect(token.trim(), isNotEmpty);
    }
  });

  test('las claves por marca están normalizadas', () {
    final keys = [
      ...ModelGroupingConfig.brandVariantTrailingTokens.keys,
      ...ModelGroupingConfig.protectedModelFamilies.keys,
    ];
    for (final key in keys) {
      expect(key, TextNormalizer.normalize(key));
    }
    expect(ModelGroupingConfig.brandVariantTrailingTokens, contains('audi'));
    expect(
      ModelGroupingConfig.protectedModelFamilies['landrover'],
      contains('Range Rover Sport'),
    );
  });

  test('los patrones quitan paréntesis y separan por espacios', () {
    expect(
      'A (b) c'.replaceAll(RegExp(ModelGroupingConfig.parenthesisPattern), ''),
      'A  c',
    );
    expect('a  b\tc'.split(RegExp(ModelGroupingConfig.wordSeparatorPattern)), [
      'a',
      'b',
      'c',
    ]);
  });

  test('versionsCountLabel distingue singular y plural', () {
    expect(AppTexts.versionsCountLabel(1), '1 versión');
    expect(AppTexts.versionsCountLabel(5), '5 versiones');
  });

  test('las reglas del día 6G existen y sus claves están normalizadas', () {
    expect(ModelGroupingConfig.variantTrailingTokens, contains('gran coupe'));
    expect(ModelGroupingConfig.variantInlineTokens, contains('Sportback'));
    expect(ModelGroupingConfig.absorbingModelBases['ford'], contains('F150'));
    expect(ModelGroupingConfig.groupDisplayNames['ford']!['f150'], 'F-150');
    expect(
      ModelGroupingConfig.protectedModelFamilies['volkswagen'],
      contains('Atlas Cross Sport'),
    );
    final keys = [
      ...ModelGroupingConfig.brandVariantTrailingPatterns.keys,
      ...ModelGroupingConfig.absorbingModelBases.keys,
      ...ModelGroupingConfig.groupDisplayNames.keys,
    ];
    for (final key in keys) {
      expect(key, TextNormalizer.normalize(key));
    }
    final pattern = RegExp(
      ModelGroupingConfig.brandVariantTrailingPatterns['bmw']!.single,
      caseSensitive: false,
    );
    expect(pattern.hasMatch('xDrive40i'), isTrue);
    expect(pattern.hasMatch('sDrive28i'), isTrue);
    expect(pattern.hasMatch('xDrive'), isFalse);
  });
}
