import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/detail_test_support.dart';

void main() {
  setUpAll(disableFontFetching);

  test('detailBrandYearLabel es el estilo label con interletraje 1.2', () {
    expect(AppTextStyles.detailBrandYearLabel.letterSpacing, 1.2);
    expect(AppTextStyles.label.letterSpacing, isNot(1.2));
    expect(
      AppTextStyles.detailBrandYearLabel.fontSize,
      AppTextStyles.label.fontSize,
    );
    expect(
      AppTextStyles.detailBrandYearLabel.fontWeight,
      AppTextStyles.label.fontWeight,
    );
  });

  testWidgets('la línea MARCA · AÑO usa ese estilo con color sutil', (
    tester,
  ) async {
    await tester.pumpWidget(
      detailHost(
        const DetailTitleRowWidget(
          brand: 'Toyota',
          year: 2020,
          groupName: 'Corolla',
        ),
      ),
    );
    final text = tester.widget<Text>(find.text('TOYOTA · 2020'));
    expect(text.style?.letterSpacing, 1.2);
    expect(text.style?.color, AppColors.subtle);
  });
}
